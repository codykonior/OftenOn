Task default -depends Compile

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function ConvertFrom-CIDR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ $_ -match "(.*)\/(\d+)" })]
        [string] $IPAddress
    )

    Write-Verbose ($IPAddress -match "(.*)\/(\d+)")
    $ip = [IPAddress] $Matches[1]
    $suffix = [int] $Matches[2]
    $mask = ("1" * $suffix) + ("0" * (32 - $suffix))
    $mask = [IPAddress] ([Convert]::ToUInt64($mask, 2))

    Write-Verbose "IP $ip CIDR $suffix MASK $mask"

    @{
        IPAddress = $ip
        CIDR = $IPAddress
        CIDRSuffix = $suffix
        NetworkID = ([IPAddress] ($ip.Address -band $mask.Address)).IPAddressToString
        SubnetMask = $mask.IPAddressToString
    }
}

function ConvertTo-CIDR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $IPAddress,
        [Parameter(Mandatory)]
        [string] $SubnetMask
    )

    $ip = [IPAddress] $IPAddress
    $mask = [IPAddress] $SubnetMask
    Write-Verbose ($mask.IPAddressToString -match '(.*)\.(.*)\.(.*)\.(.*)')
    $suffix = ""
    $Matches[1..4] | ForEach-Object {
        $suffix += [Convert]::ToString([int] $_, 2) + ("0" * (8 - [Convert]::ToString([int] $_, 2).Length))
    }
    $suffix = ($suffix -split "[^1]")[0].Length

    @{
        IPAddres     = $IPAddress
        CIDR         = "$IPAddress/$suffix"
        CIDRSuffix   = $suffix
        NetworkID    = ([IPAddress] ($ip.Address -band $mask.Address)).IPAddressToString
        SubnetMask   = $mask.IPAddressToString
    }
}

# Load configuration data so we can do our own manipulation
$configurationData = Import-PowerShellDataFile -Path C:\Lability\Configurations\WS2012.psd1
$configurationData.AllNodes | Where-Object { $_.NodeName -eq '*' } | ForEach-Object {
    $PSItem.CertificateFile = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer"
}

# Lability creates one NIC per entry in a SwitchName array. We also creat a Lability_MACAddress array
# to assign AdapterName to each NIC as their default names are assigned randomly < Server 2012.
foreach ($node in $configurationData.AllNodes) {
    if ($node.ContainsKey('Network')) {
        $switchName = @()
        $macAddress = @()

        foreach ($network in $node.Network) {
            $switchName += $network.SwitchName
            # It's important to limit what MAC are used otherwise you will get confusing errors during VM creation
            $macAddress += ('00', '03', (0..3 | ForEach-Object { '{0:x}{1:x}' -f (Get-Random -Minimum 0 -Maximum 15), (Get-Random -Minimum 0 -Maximum 15) }) | ForEach-Object { $_ }) -join ':'
        }

        $node.Lability_SwitchName = $switchName
        $node.Lability_MACAddress = $macAddress
    }

    if ($node.ContainsKey('Role') -and $node.Role.ContainsKey('Cluster')) {
        $node.Role.Cluster.StaticAddress = ConvertFrom-CIDR $node.Role.Cluster.StaticAddress
        $node.Role.Cluster.StaticAddress.Name = "Cluster Network " + ($node.Network | Where-Object { (ConvertFrom-CIDR $_.IPAddress).NetworkID -eq $node.Role.Cluster.StaticAddress.NetworkID }).NetAdapterName + " (Client)"
        $node.Role.Cluster.IgnoreNetwork = ConvertFrom-CIDR $node.Role.Cluster.IgnoreNetwork
        $node.Role.Cluster.IgnoreNetwork.Name = "Cluster Network " + ($node.Network | Where-Object { (ConvertFrom-CIDR $_.IPAddress).NetworkID -eq $node.Role.Cluster.IgnoreNetwork.NetworkID }).NetAdapterName + " (Heartbeat)"
    }
}

Task FixRDP {
    # Fix local RDP client
    if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP)) {
        New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP
    }
    if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters)) {
        New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters
    }
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -Name 'AllowEncryptionOracle' -Value 2 -Type DWord
}

Task Compile {
    . .\WS2012.ps1
    WS2012 -ConfigurationData $configurationData -OutputPath C:\Lability\Configurations
}

<#
Task Extract {
    if (!(Test-Path C:\Lability\Resources\Net-Framework-Core.zip)) {
        $volume = Mount-DiskImage -Access ReadOnly -StorageType ISO -ImagePath C:\Lability\ISOs\9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO -PassThru | Get-Volume
        Compress-Archive -Path "$($volume.DriveLetter):\Sources\sxs" -DestinationPath C:\Lability\Resources\Net-Framework-Core.zip
        Dismount-DiskImage -ImagePath C:\Lability\ISOs\9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO
    }
}
#>

Task Build -depends Compile {
    $administrator = New-Object System.Management.Automation.PSCredential('Administrator', ('Admin2018!' | ConvertTo-SecureString -AsPlainText -Force))
    Start-LabConfiguration -ConfigurationData $configurationData -IgnorePendingReboot -Credential $administrator -NoSnapshot
}

Task Start {
    "Allow at least 15 minutes for the first boot to finish Domain Controller setup"
    Start-Lab -ConfigurationData $configurationData
}

Task BuildAll -Depends Clean, Build, Start {
}

Task Stop {
    Stop-Lab -ConfigurationData $configurationData -ErrorAction:SilentlyContinue
}

Task Clean -depends Stop {
    Remove-LabConfiguration -ConfigurationData C:\Lability\Configurations\WS2012.psd1 -ErrorAction:SilentlyContinue -Confirm:$false
    Remove-Item C:\Lability\VMVirtualHardDisks\*
}

Task CleanAll -depends Clean {
    Remove-Item C:\Lability\MasterVirtualHardDisks\*
}

<#

Add node to cluster can have an error which triggers a 15 minute wait.
Having a WAN causes everything to fail. Confirm one more time, then set NICs to Private instead of Internal.

TODO
    Create SQL AG
        clussvc is no good it seems, for creating an ag
        grant view server state to [nt authority\system]
        grant alter any availability group to [nt authority\system]
        change to service accounts also
        grant connect endpoint to service account

    Create MSA accounts
    Add modules SqlServer, DbaTools, Cim, DbData, Jojoba, Error
    Add SecurityPolicyDsc permissions
    Add DHCP for local host RDP

How to set up WAN routing
    Install-RemoteAccess -VpnType Vpn
    cmd.exe /c 'netsh routing ip nat install'
    $ExternalInterface = 'External'
    cmd.exe /c 'netsh routing ip nat add interface $ExternalInterface'
    cmd.exe /c 'netsh routing ip nat set interface $ExternalInterface mode=full'
    $InternalInterface1 = 'LAN1'
    $InternalInterface2 = 'LAN2'
    cmd.exe /c 'netsh routing ip nat add interface $InternalInterface1'
    cmd.exe /c 'netsh routing ip nat add interface $InternalInterface2'

#>
