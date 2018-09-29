param([switch] $Clean)

<#
TODO:
    Clean up use of Network into a hash table
    Clean up use of LAN names
    Add a SQL resource
    Set up SQL
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

<#
# How to set up WAN routing
Install-RemoteAccess -VpnType Vpn
cmd.exe /c 'netsh routing ip nat install'
cmd.exe /c 'netsh routing ip nat add interface $ExternalInterface'
 $ExternalInterface = 'External'
$InternalInterface1 = 'LAN1'
$InternalInterface2 = 'LAN2'
$InternalInterface3 = 'LAN3'
$InternalInterface4 = 'LAN4'
cmd.exe /c 'netsh routing ip nat set interface $ExternalInterface mode=full'
cmd.exe /c 'netsh routing ip nat add interface $InternalInterface1'
cmd.exe /c 'netsh routing ip nat add interface $InternalInterface2'
cmd.exe /c 'netsh routing ip nat add interface $InternalInterface3'
cmd.exe /c 'netsh routing ip nat add interface $InternalInterface4'
#>

# Outgoing interface on host needs an IP - maybe this would be better with DHCP enabled
Configuration WS2012 {
    param (
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName NetworkingDsc
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xFailOverCluster
    Import-DscResource -ModuleName xDnsServer
    Import-DscResource -ModuleName xRemoteDesktopAdmin
    Import-DscResource -ModuleName xSmbShare

    Node $AllNodes.NodeName {
        $domainAdministrator = New-Object System.Management.Automation.PSCredential("LAB\Administrator", ("Admin2018!" | ConvertTo-SecureString -AsPlainText -Force))
        $safemodeAdministrator = New-Object System.Management.Automation.PSCredential("Administrator", ("Safe2018!" | ConvertTo-SecureString -AsPlainText -Force))

        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode    = "ApplyOnly"
            CertificateID        = $node.Thumbprint
        }

        # Don't cache no-results for 15 minutes, like looking up the cluster name
        Registry "DisableNegativeCacheTtl" {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
            ValueName = "MaxNegativeCacheTtl"
            ValueData = "0"
            ValueType = "DWord"
        }
        
        # So you can rollback snapshots after more than 30 days
        Registry "DisableMachineAccountPasswordChange" {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
            ValueName = "DisablePasswordChange"
            ValueData = "1"
            ValueType = "DWord"
        }

        if ($node.ContainsKey("Lability_MACAddress")) {
            for ($i = 0; $i -lt @($node.Lability_MACAddress).Count; $i++) {
                NetAdapterName "RenameNetAdapter$i" {
                    NewName    = $node.NetworkAdapterName[$i];
                    MacAddress = $node.Lability_MACAddress[$i].Replace(":", "-");
                }

                if ($node.IPAddress[$i]) {
                    IPAddress "SetIPAddress$i" {
                        AddressFamily = "IPv4"
                        InterfaceAlias = $node.NetworkAdapterName[$i]
                        IPAddress = $node.IPAddress[$i]
                        DependsOn = "[NetAdapterName]RenameNetAdapter$i"
                    }
                }

                if ($node.ContainsKey("GatewayAddress")) {
                    DefaultGatewayAddress "SetDefaultGatewayAddress$i" {
                        Address = $node.GatewayAddress
                        InterfaceAlias = $node.NetworkAdapterName[$i]
                        AddressFamily = "IPv4"
                        DependsOn = "[NetAdapterName]RenameNetAdapter$i"
                    }
                }
            }
        }

        foreach ($firewallRule in @("FPS-ICMP4-ERQ-In", "FPS-ICMP6-ERQ-In", "RemoteDesktop-UserMode-In-TCP", "RemoteDesktop-UserMode-In-UDP")) {
            # It used to be that you had to specify all the details. But no, now you can just turn on an existing rule.
            Firewall $firewallRule.Replace("-", "") {
                Name    = $firewallRule
                Ensure  = "Present"
                Enabled = "True"
            }    
        }

        xRemoteDesktopAdmin "RDP" {
            Ensure             = "Present"
            UserAuthentication = "NonSecure"
        }

        $windowsFeatures = "RSAT-AD-Tools", "RSAT-AD-PowerShell", "RSAT-Clustering", "RSAT-Clustering-CmdInterface", "RSAT-DNS-Server", "RSAT-RemoteAccess"
        switch -Wildcard ($node.Role) {
            "DomainController" {
                $windowsFeatures += "AD-Domain-Services", "DNS", "Routing"
            }
            "*ClusterNode" {
                $windowsFeatures += "Failover-Clustering"
            }
        }

        foreach ($windowsFeature in $windowsFeatures) {
            WindowsFeature $windowsFeature.Replace("-", "") {
                Ensure = "Present"
                Name   = $windowsFeature
            }
        }

        if ($node.Role -eq "DomainController") {
            Computer "Name" {
                Name = $node.NodeName
            }

            xSmbShare AddResourceShare {
                Name = "Resources"
                Path = "C:\Resources"
                ReadAccess = "Everyone"
                Ensure = "Present"
            }

            Script SetIPInterfaceForwardingEnabled {
                GetScript = {
                }
                TestScript = {
                    if (Get-NetIPInterface | Where-Object { $_.InterfaceAlias -like "LAN*" -and $_.Forwarding -ne "Enabled" }) {
                        $false
                    } else {
                        $true
                    }
                }
                SetScript = {
                    Get-NetIPInterface | Where-Object { $_.InterfaceAlias -like "LAN*" } | Set-NetIPInterface -Forwarding Enabled
                }
                DependsOn      = "[Computer]Name"
            }    

            DnsServerAddress "DNSServer1" {
                Address        = $node.DnsServerAddress
                InterfaceAlias = "LAN_10_0_0"
                AddressFamily  = "IPv4"
                DependsOn      = "[Computer]Name", "[WindowsFeature]DNS"
            }
            DnsServerAddress "DNSServer2" {
                Address        = $node.DnsServerAddress
                InterfaceAlias = "LAN_10_0_1"
                AddressFamily  = "IPv4"
                DependsOn      = "[Computer]Name", "[WindowsFeature]DNS"
            }
            DnsServerAddress "DNSServer3" {
                Address        = $node.DnsServerAddress
                InterfaceAlias = "LAN_10_0_2"
                AddressFamily  = "IPv4"
                DependsOn      = "[Computer]Name", "[WindowsFeature]DNS"
            }

            xADDomain "Domain" {
                DomainName                    = $node.DomainName
                DomainAdministratorCredential = $domainAdministrator
                SafemodeAdministratorPassword = $safemodeAdministrator

                DependsOn                     = "[WindowsFeature]ADDomainServices"
            }
        }
        else {
            # If DNS is not defined computers can not be joined to the domain
            DnsServerAddress "PrimaryDNSClient" {
                Address        = $node.DnsServerAddress
                InterfaceAlias = "LAN"
                AddressFamily  = "IPv4"
            }

            DnsConnectionSuffix "PrimaryConnectionSuffix" {
                ConnectionSpecificSuffix = $node.DomainName
                InterfaceAlias           = "LAN"
            }
        }

        if ($node.Role -like "*ClusterNode") {
            xWaitForADDomain "Join" {
                DomainName           = $node.DomainName
                DomainUserCredential = $domainAdministrator
                # 30 Minutes
                RetryIntervalSec     = 15
                RetryCount           = 120
            }

            Computer "Name" {
                Name       = $node.NodeName
                DomainName = $node.DomainName
                Credential = $domainAdministrator
                DependsOn  = "[xWaitForADDomain]Join"
            }

            if ($node.Role -eq "FirstClusterNode") {
                xCluster "Cluster" {
                    Name                          = "C1"
                    DomainAdministratorCredential = $domainAdministrator
                    StaticIPAddress               = $node.ClusterIPAddress
                    # If RSAT-Clustering is not installed the cluster can not be created
                    DependsOn                     = "[WindowsFeature]FailoverClustering", "[WindowsFeature]RSATClustering", "[Computer]Name"
                }
            }
            else {
                xWaitForCluster "Up" {
                    Name             = "C1"
                    DependsOn        = "[WindowsFeature]FailoverClustering", "[WindowsFeature]RSATClustering", "[Computer]Name"
                    # 30 Minutes
                    RetryIntervalSec = 15
                    RetryCount       = 120
                }

                xCluster "Cluster" {
                    Name                          = "C1"
                    DomainAdministratorCredential = $domainAdministrator
                    StaticIPAddress               = $node.ClusterIPAddress
                    DependsOn                     = "[xWaitForCluster]Up"
                }

                Script "ClusterIPAddress" {
                    GetScript = {
                    }
                    TestScript = {
                        $clusterIPAddress = ($using:node.ClusterIPAddress -split "/")[0]
                        if (Get-Cluster | Get-ClusterResource | Where-Object { $_.ResourceType -eq "IP Address" } | Get-ClusterParameter -Name Address | Where-Object { $_.Value -eq $clusterIPAddress }) {
                            $true
                        } else {
                            $false
                        }
                    }
                    SetScript = {
                        $clusterIPAddress = ($using:node.ClusterIPAddress -split "/")[0]
                        Get-Cluster | Add-ClusterResource -Name "IP Address $clusterIPAddress" -Group "Cluster Group" -ResourceType "IP Address"
                        $network = Get-Cluster | Get-ClusterNetwork | Where-Object { (([Net.IPAddress] $_.Address).Address -band ([Net.IPAddress] $_.AddressMask).Address) -eq (([Net.IPAddress] $clusterIPAddress).Address -band ([Net.IPAddress] $_.AddressMask).Address)}
                        Get-Cluster | Get-ClusterResource -Name "IP Address $clusterIPAddress" | Set-ClusterParameter -Multiple @{ Address = $clusterIPAddress; Network = $network.Name; SubnetMask = $network.AddressMask; }
                        $expression = (Get-Cluster | Get-ClusterResourceDependency -Resource "Cluster Name").DependencyExpression
                        if ($expression -match "^\((.*)\)$") {
                            $expression = $Matches[1] + " or [IP Address $clusterIPAddress]"
                        } else {
                            $expression = $expression + " or [IP Address $clusterIPAddress]"
                        }
                        Get-Cluster | Set-ClusterResourceDependency -Resource "Cluster Name" -Dependency $expression
                        # Without this, it won't start automatically on first try
                        (Get-Cluster | Get-ClusterResource -Name "IP Address $clusterIPAddress").PersistentState = 1
                    }
                    DependsOn = "[xCluster]Cluster"
                }
            }

        }
    }
}

$configurationData = Import-PowerShellDataFile -Path C:\Lability\Configurations\WS2012.psd1
$certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$certificate.Import("$env:AllUsersProfile\Lability\Certificates\LabClient.cer")
$configurationData.AllNodes[0].CertificateFile = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer"
$configurationData.AllNodes[0].Thumbprint = $certificate.Thumbprint

foreach ($node in $configurationData.AllNodes) {
    if ($node.ContainsKey("Lability_SwitchName")) {
        $macAddress = @()
        foreach ($switchName in $node.Lability_SwitchName) {
            # It's important to limit what MAC are used otherwise you will get weird failures on VM creation
            $macAddress += ('00', '03', (0..3 | ForEach-Object { '{0:x}{1:x}' -f (Get-Random -Minimum 0 -Maximum 15),(Get-Random -Minimum 0 -Maximum 15)}) | ForEach-Object { $_ }) -join ':'
        }

        $node.Lability_MACAddress = $macAddress
    }
}

WS2012 -ConfigurationData $configurationData -OutputPath C:\Lability\Configurations

if ($Clean) {
    # Clean up
    Remove-LabConfiguration -ConfigurationData C:\Lability\Configurations\WS2012.psd1 -ErrorAction:SilentlyContinue -Confirm:$false
    Remove-Item C:\Lability\VMVirtualHardDisks\*
    $error.Clear()
}

# Build
$administrator = New-Object System.Management.Automation.PSCredential("Administrator", ("Admin2018!" | ConvertTo-SecureString -AsPlainText -Force))
Start-LabConfiguration -ConfigurationData $configurationData -IgnorePendingReboot -Credential $administrator

# Start
Start-Lab -ConfigurationData $configurationData

# Fix local RDP client
if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP)) {
    New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP
}
if (!(Test-Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters)) {
    New-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters
}
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters' -Name "AllowEncryptionOracle" 2 -Type DWord
