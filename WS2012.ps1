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

    Node $AllNodes.NodeName {
        $domainAdministrator = New-Object System.Management.Automation.PSCredential("LAB\Administrator", ("Admin2018!" | ConvertTo-SecureString -AsPlainText -Force))
        $safemodeAdministrator = New-Object System.Management.Automation.PSCredential("Administrator", ("Safe2018!" | ConvertTo-SecureString -AsPlainText -Force))

        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode    = "ApplyOnly"
            CertificateID        = $node.Thumbprint
        }

        IPAddress "IPAddress" {
            AddressFamily  = "IPv4"
            InterfaceAlias = "Ethernet"
            IPAddress      = $node.IPAddress
        }

        # Unchecked
        Firewall "FPS-ICMP4-ERQ-In" {
            Name        = "FPS-ICMP4-ERQ-In"
            DisplayName = "File and Printer Sharing (Echo Request - ICMPv4-In)"
            Description = "Echo request messages are sent as ping requests to other nodes."
            Direction   = "Inbound"
            Action      = "Allow"
            Enabled     = "True"
            Profile     = "Any"
        }

        Firewall "FPS-ICMP6-ERQ-In" {
            Name        = "FPS-ICMP6-ERQ-In"
            DisplayName = "File and Printer Sharing (Echo Request - ICMPv6-In)"
            Description = "Echo request messages are sent as ping requests to other nodes."
            Direction   = "Inbound"
            Action      = "Allow"
            Enabled     = "True"
            Profile     = "Any"
        }

        switch -Wildcard ($node.Role) {
            "DomainController" {
                $windowsFeatures = "AD-Domain-Services", "DNS", "RSAT-AD-Tools", "RSAT-DNS-Server", "RSAT-Clustering" #, "Routing", "RSAT-RemoteAccess"
            }
            "*ClusterNode" {
                $windowsFeatures = "Failover-Clustering", "RSAT-Clustering"
            }
            default {
                $windowsFeatures = @()
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

            DnsServerAddress "DNSServer" {
                Address        = $node.DnsServerAddress
                InterfaceAlias = "Ethernet"
                AddressFamily  = "IPv4"
                DependsOn      = "[Computer]Name", "[WindowsFeature]DNS"
            }

            xADDomain "Domain" {
                DomainName                    = $node.DomainName
                DomainAdministratorCredential = $domainAdministrator
                SafemodeAdministratorPassword = $safemodeAdministrator

                DependsOn                     = "[DnsServerAddress]DNSServer", "[WindowsFeature]ADDomainServices"
            }
        }
        else {
            # If DNS is not defined computers can not be joined to the domain
            DnsServerAddress "PrimaryDNSClient" {
                Address        = $node.DnsServerAddress
                InterfaceAlias = "Ethernet"
                AddressFamily  = "IPv4"
            }

            DnsConnectionSuffix "PrimaryConnectionSuffix" {
                ConnectionSpecificSuffix = $node.DomainName
                InterfaceAlias           = "Ethernet"
            }
        }

        if ($node.Role -like "*ClusterNode") {
            xWaitForADDomain "Join" {
                DomainName           = $node.DomainName
                DomainUserCredential = $domainAdministrator
                RetryCount           = 60
                RetryIntervalSec     = 10
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
                    StaticIPAddress               = "10.0.0.21/24"
                    # If RSAT-Clustering is not installed the cluster can not be created
                    DependsOn                     = "[WindowsFeature]FailoverClustering", "[WindowsFeature]RSATClustering", "[Computer]Name"
                }
            }
            else {
                xWaitForCluster "Up" {
                    Name             = "C1"
                    RetryIntervalSec = 10
                    RetryCount       = 60
                    DependsOn        = "[WindowsFeature]FailoverClustering", "[WindowsFeature]RSATClustering", "[Computer]Name"
                }

                xCluster "Cluster" {
                    Name                          = "C1"
                    DomainAdministratorCredential = $domainAdministrator
                    StaticIPAddress               = "10.0.0.21/24"
                    DependsOn                     = "[xWaitForCluster]Up"
                }
            }

        }
    }
}
WS2012 -ConfigurationData C:\Lability\Configurations\WS2012.psd1 -OutputPath C:\Lability\Configurations

# Clean up
Remove-LabConfiguration -ConfigurationData C:\Lability\Configurations\WS2012.psd1 -ErrorAction:SilentlyContinue -Confirm:$false
Remove-Item C:\Lability\VMVirtualHardDisks\*

# Build
$administrator = New-Object System.Management.Automation.PSCredential("Administrator", ("Admin2018!" | ConvertTo-SecureString -AsPlainText -Force))
Start-LabConfiguration -ConfigurationData C:\Lability\Configurations\WS2012.psd1 -IgnorePendingReboot -Credential $administrator

# Start
Start-Lab -ConfigurationData C:\Lability\Configurations\WS2012.psd1
