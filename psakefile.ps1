Task default -depends Compile

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
}

Task FixRDP {
    # Fix local RDP client
    if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP)) {
        New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP
    }
    if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters)) {
        New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters
    }
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -Name 'AllowEncryptionOracle' 2 -Type DWord
}

Task Compile {
    . .\WS2012.ps1
    WS2012 -ConfigurationData $configurationData -OutputPath C:\Lability\Configurations
}

Task Build -depends Compile {
    $administrator = New-Object System.Management.Automation.PSCredential('Administrator', ('Admin2018!' | ConvertTo-SecureString -AsPlainText -Force))
    Start-LabConfiguration -ConfigurationData $configurationData -IgnorePendingReboot -Credential $administrator -NoSnapshot
}

Task Start {
    "Allow at least 15 minutes for the first boot to finish Domain Controller setup"
    Start-Lab -ConfigurationData $configurationData
}

Task Stop {
    Stop-Lab -ConfigurationData $configurationData
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
    Install SQL
    Create SQL AG
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
