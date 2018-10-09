Task default -depends Compile

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Network translation functions
function ConvertFrom-CIDR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( { $_ -match "(.*)\/(\d+)" })]
        [string] $IPAddress
    )

    Write-Verbose ($IPAddress -match "(.*)\/(\d+)")
    $ip = [IPAddress] $Matches[1]
    $suffix = [int] $Matches[2]
    $mask = ("1" * $suffix) + ("0" * (32 - $suffix))
    $mask = [IPAddress] ([Convert]::ToUInt64($mask, 2))

    Write-Verbose "IP $ip CIDR $suffix MASK $mask"

    @{
        IPAddress  = $ip
        CIDR       = $IPAddress
        CIDRSuffix = $suffix
        NetworkID  = ([IPAddress] ($ip.Address -band $mask.Address)).IPAddressToString
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
        IPAddres   = $IPAddress
        CIDR       = "$IPAddress/$suffix"
        CIDRSuffix = $suffix
        NetworkID  = ([IPAddress] ($ip.Address -band $mask.Address)).IPAddressToString
        SubnetMask = $mask.IPAddressToString
    }
}
#endregion

#region Always-run, manipulate configuration data encryption information
$configurationData = Import-PowerShellDataFile -Path C:\Lability\Configurations\WS2012.psd1
$configurationData.AllNodes | Where-Object { $_.NodeName -eq '*' } | ForEach-Object {
    $PSItem.CertificateFile = $PSItem.CertificateFile.Replace('$env:ALLUSERSPROFILE', $env:ALLUSERSPROFILE)
    $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $certificate.Import($PSItem.CertificateFile)
    $PSItem.Thumbprint = $certificate.Thumbprint
}
#endregion

#region Always-run, manipulate configuration data network information
foreach ($node in $configurationData.AllNodes) {
    <#
        Lability creates one NIC for each entry in the Lability_SwitchName array. We put these into a Network
        array instead so that we have more fine-grained control.

        We use that to populate Lability_SwitchName and Lability_MACAddress which assigns a random MAC. This
        is used later to match up with the network AdapterName and rename the NIC.

        This must be done because most versions of Windows assign default NIC names in an uncontrolled manner.
    #>
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

    <#
        Different xFailoverCluster resources need different combinations of IP, CIDR, and Subnet. This splits
        out all of the different variations for easy use during configuration.
    #>
    if ($node.ContainsKey('Role') -and $node.Role.ContainsKey('Cluster')) {
        $node.Role.Cluster.StaticAddress = ConvertFrom-CIDR $node.Role.Cluster.StaticAddress
        $node.Role.Cluster.StaticAddress.Name = "Cluster Network " + ($node.Network | Where-Object { (ConvertFrom-CIDR $_.IPAddress).NetworkID -eq $node.Role.Cluster.StaticAddress.NetworkID }).NetAdapterName + " (Client)"
        $node.Role.Cluster.IgnoreNetwork = ConvertFrom-CIDR $node.Role.Cluster.IgnoreNetwork
        $node.Role.Cluster.IgnoreNetwork.Name = "Cluster Network " + ($node.Network | Where-Object { (ConvertFrom-CIDR $_.IPAddress).NetworkID -eq $node.Role.Cluster.IgnoreNetwork.NetworkID }).NetAdapterName + " (Heartbeat)"
    }
}
#endregion

#region Apply a local RDP fix so that it can connect to unpatched RDP servers such as will be in our VMs.
Task FixRDP {
    if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP)) {
        New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP
    }
    if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters)) {
        New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters
    }
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -Name 'AllowEncryptionOracle' -Value 2 -Type DWord
}
#endregion

#region Just compile the MOF resources
Task Compile {
    . .\WS2012.ps1
    WS2012 -ConfigurationData $configurationData -OutputPath C:\Lability\Configurations
}
#endregion

#region Compile the MOF resources and configure the lab VMs
Task Build -depends Compile {
    $administrator = New-Object System.Management.Automation.PSCredential('Administrator', ('Admin2018!' | ConvertTo-SecureString -AsPlainText -Force))
    Start-LabConfiguration -ConfigurationData $configurationData -IgnorePendingReboot -Credential $administrator -NoSnapshot
}
#endregion

#region Start the lab VMs
Task Start {
    "Allow at least 15 minutes for the first boot to finish Domain Controller setup"
    Start-Lab -ConfigurationData $configurationData
}
#endregion

#region Remove existing VMs, then compile the MOF resources, configure the lab VMs, and start the lab VMs
Task BuildAll -Depends Clean, Build, Start {
}
#endregion

#region Stop the lab VMs
Task Stop {
    Stop-Lab -ConfigurationData $configurationData -ErrorAction:SilentlyContinue
}
#endregion

#region Remove existing VMs
Task Clean -depends Stop {
    Remove-LabConfiguration -ConfigurationData C:\Lability\Configurations\WS2012.psd1 -ErrorAction:SilentlyContinue -Confirm:$false
    Remove-Item C:\Lability\VMVirtualHardDisks\*
}
#endregion

#region Remove existing VMs and also master hard disks so the server OS is rebuilt
Task CleanAll -depends Clean {
    Remove-Item C:\Lability\MasterVirtualHardDisks\*
}
#endregion

<#

Add node to cluster can have an error which triggers a 15 minute wait.
Having a WAN causes everything to fail. Confirm one more time, then set NICs to Private instead of Internal.

TODO
    Change order of resource processing so SQL gets installed earlier
    Create MSA accounts
    Add SecurityPolicyDsc permissions
    Create RDCMan
    Try adding a WAN card

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
