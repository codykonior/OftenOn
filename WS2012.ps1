# Try manual run on DA node to check for listener IP working
# Modify database add to AG with WaitForAll
Configuration WS2012 {
    param (
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName NetworkingDsc
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName C:\xFailOverCluster
    Import-DscResource -ModuleName xDnsServer
    Import-DscResource -ModuleName xRemoteDesktopAdmin
    Import-DscResource -ModuleName xSmbShare
    Import-DscResource -ModuleName SqlServerDsc

    $clusterOrder = @{}
    $availabilityReplicaOrder = @{}

    Node $AllNodes.NodeName {
        $domainAdministrator = New-Object System.Management.Automation.PSCredential('LAB\Administrator', ('Admin2018!' | ConvertTo-SecureString -AsPlainText -Force))
        $safemodeAdministrator = New-Object System.Management.Automation.PSCredential('Administrator', ('Safe2018!' | ConvertTo-SecureString -AsPlainText -Force))
        $localAdministrator = New-Object System.Management.Automation.PSCredential('LAB\LocalAdministrator', ('Local2018!' | ConvertTo-SecureString -AsPlainText -Force))
        $sqlEngineServiceC1 = New-Object System.Management.Automation.PSCredential('LAB\SQLEngineServiceC1', ('Engine2018!' | ConvertTo-SecureString -AsPlainText -Force))

        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            CertificateID        = $node.Thumbprint

            # This retries the configuration every 15 minutes (the minimum) until it has entirely passed once
            ConfigurationMode    = 'ApplyOnly'
            ConfigurationModeFrequencyMins = 15
        }

        # Windows will cache "not found" results for 15 minutes which slows down configurations
        # that check for a Cluster being alive, so we disable caching
        Registry 'DisableNegativeCacheTtl' {
            Ensure = 'Present'
            Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
            ValueName = 'MaxNegativeCacheTtl'
            ValueData = '0'
            ValueType = 'DWord'
        }

        # Windows cycles machine passwords in a domain which prevents you from restoring a
        # snapshot older than 30 days, so we disable this
        Registry 'DisableMachineAccountPasswordChange' {
            Ensure = 'Present'
            Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
            ValueName = 'DisablePasswordChange'
            ValueData = '1'
            ValueType = 'DWord'
        }

        # Enable ping requests and incoming Remote Desktop
        foreach ($firewallRule in @('FPS-ICMP4-ERQ-In', 'FPS-ICMP6-ERQ-In', 'RemoteDesktop-UserMode-In-TCP', 'RemoteDesktop-UserMode-In-UDP')) {
            # In current versions of DSC you can pass a built-in rule name and enable it without
            # specifying all of the other details
            Firewall "EnableFirewallRule$($firewallRule.Replace('-', ''))" {
                Name    = $firewallRule
                Ensure  = 'Present'
                Enabled = 'True'
            }
        }

        # Enable Remote Desktop
        xRemoteDesktopAdmin 'EnableRemoteDesktop' {
            Ensure             = 'Present'
            UserAuthentication = 'NonSecure'
        }

        # Enable windows features
        $windowsFeatures = 'RSAT-AD-Tools', 'RSAT-AD-PowerShell', 'RSAT-Clustering', 'RSAT-Clustering-CmdInterface', 'RSAT-DNS-Server', 'RSAT-RemoteAccess'
        if ($node.ContainsKey('Role') -and $node.Role.ContainsKey('DomainController')) {
            $windowsFeatures += 'AD-Domain-Services', 'DNS', 'Routing'
        }
        if ($node.ContainsKey('Role') -and $node.Role.ContainsKey('Cluster')) {
            $windowsFeatures += 'Failover-Clustering'
        }

        foreach ($windowsFeature in $windowsFeatures) {
            WindowsFeature "AddWindowsFeature$($windowsFeature.Replace('-', ''))" {
                Ensure = 'Present'
                Name   = $windowsFeature
            }
        }

        # Define each network adapter name, IP address, default gateway address, DNS server address, and DNS connection suffix
        if ($node.ContainsKey('Network')) {
            for ($i = 0; $i -lt $node.Network.Count; $i++) {
                $network = $node.Network[$i]

                NetAdapterName "RenameNetAdapterName$($network.NetAdapterName)" {
                    NewName = $network.NetAdapterName
                    MacAddress = $node.Lability_MACAddress[$i].Replace(':', '-')
                }

                if ($network.ContainsKey('IPAddress')) {
                    IPAddress "SetIPAddress$($network.NetAdapterName)" {
                        AddressFamily = 'IPv4'
                        InterfaceAlias = $network.NetAdapterName
                        IPAddress = $network.IPAddress
                        DependsOn = "[NetAdapterName]RenameNetAdapterName$($network.NetAdapterName)"
                    }
                }

                if ($network.ContainsKey('DefaultGatewayAddress')) {
                    DefaultGatewayAddress "SetDefaultGatewayAddress$($network.NetAdapterName)" {
                        AddressFamily = 'IPv4'
                        InterfaceAlias = $network.NetAdapterName
                        Address = $network.DefaultGatewayAddress
                        DependsOn = "[NetAdapterName]RenameNetAdapterName$($network.NetAdapterName)"
                    }
                }

                if ($network.ContainsKey('DnsServerAddress')) {
                    DnsServerAddress "SetDnsServerAddress$($network.NetAdapterName)" {
                        AddressFamily  = 'IPv4'
                        InterfaceAlias = $network.NetAdapterName
                        Address        = $network.DnsServerAddress
                        DependsOn = "[NetAdapterName]RenameNetAdapterName$($network.NetAdapterName)"
                    }
                }

                DnsConnectionSuffix "SetDnsConnectionSuffix$($network.NetAdapterName)" {
                    InterfaceAlias           = $network.NetAdapterName
                    ConnectionSpecificSuffix = $node.DomainName
                    DependsOn = "[NetAdapterName]RenameNetAdapterName$($network.NetAdapterName)"
                }
            }
        }

        File 'CreateTempDirectory' {
            DestinationPath = 'C:\Temp'
            Ensure = 'Present'
            Type = 'Directory'
        }

        if ($node.ContainsKey('Role')) {
            if ($node.Role.ContainsKey('DomainController')) {
                Computer 'RenameComputer' {
                    Name = $node.NodeName
                }

                Script 'SetNetIPInterfaceForwardingEnabled' {
                    GetScript = {
                    }
                    TestScript = {
                        if (Get-NetIPInterface | Where-Object { $_.Forwarding -ne 'Enabled' }) {
                            $false
                        } else {
                            $true
                        }
                    }
                    SetScript = {
                        Get-NetIPInterface | Where-Object { $_.Forwarding -ne 'Enabled' } | Set-NetIPInterface -Forwarding Enabled
                    }

                    DependsOn      = '[Computer]RenameComputer'
                }

                xADDomain 'CreateDomain' {
                    DomainName                    = $node.DomainName
                    DomainAdministratorCredential = $domainAdministrator
                    SafemodeAdministratorPassword = $safemodeAdministrator

                    DependsOn                     = '[WindowsFeature]AddWindowsFeatureADDomainServices'
                }

                xADUser "CreateSQLEngineServiceC1User" {
                    DomainName  = $node.DomainName
                    UserName    = 'SQLEngineServiceC1'
                    Description = 'SQL Engine for Cluster 1'
                    Password    = $sqlEngineServiceC1
                    Ensure      = 'Present'
                    DependsOn   = '[xADDomain]CreateDomain'
                }

                xADUser "CreateLocalAdministratorUser" {
                    DomainName  = $node.DomainName
                    UserName    = 'LocalAdministrator'
                    Description = 'Local Administrator'
                    Password    = $localAdministrator
                    Ensure      = 'Present'
                    DependsOn   = '[xADDomain]CreateDomain'
                }

                # Define a share with all of our Lability_Resources so clients can use them for installs
                xSmbShare 'AddResourceShare' {
                    Name = 'Resources'
                    Ensure = 'Present'

                    Path = 'C:\Resources'
                    ReadAccess = 'Everyone'

                    DependsOn = '[xADDomain]CreateDomain'
                }

                xSmbShare 'AddTempShare' {
                    Name = 'Temp'
                    Ensure = 'Present'

                    Path = 'C:\Temp'
                    FullAccess = 'Everyone'

                    DependsOn = '[xADDomain]CreateDomain'
                }
            } else {
                xWaitForADDomain 'WaitForCreateDomain' {
                    DomainName           = $node.DomainName
                    DomainUserCredential = $domainAdministrator
                    # 30 Minutes
                    RetryIntervalSec     = 15
                    RetryCount           = 120
                }

                Computer 'RenameComputer' {
                    Name       = $node.NodeName
                    DomainName = $node.DomainName
                    Credential = $domainAdministrator
                    DependsOn  = '[xWaitForADDomain]WaitForCreateDomain'
                }
            }

            WaitForAny "WaitForLocalAdministratorUser" {
                ResourceName = '[xADUser]CreateLocalAdministratorUser'
                NodeName = 'CHDC1'

                # 30 Minutes
                RetryIntervalSec = 15
                RetryCount       = 120
            }

            Group 'AddLocalAdministratorToAdministrators' {
                GroupName = 'Administrators'
                # Credential = $domainAdministrator
                Ensure = 'Present'
                MembersToInclude = $localAdministrator.UserName
                DependsOn = '[WaitForAny]WaitForLocalAdministratorUser'
            }

            # Despite the name, this is required to allow you to RDP to the server from your host (except for DC where it just works)
            # This seems to happen by sudden replies to the computer name with an accessible IPv6 address
            Script 'EnableFileAndPrinterSharing' {
                GetScript = {
                }
                TestScript = {
                    if (Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' | Where-Object { $_.Enabled -eq 'False' }) {
                        $false
                    } else {
                        $true
                    }
                }
                SetScript = {
                    Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' | Where-Object { $_.Enabled -eq 'False' } | Set-NetFirewallRule -Enabled True
                }

                DependsOn      = '[Computer]RenameComputer'
            }
            if ($node.Role.ContainsKey('Cluster')) {
                $cluster = $node.Role.Cluster
                $clusterStaticAddress = $cluster.StaticAddress
                $clusterIgnoreNetwork = $cluster.IgnoreNetwork

                if (!$clusterOrder.ContainsKey($cluster.Name)) {
                    $clusterOrder.$($cluster.Name) = [array] $node.NodeName
                    xCluster "AddNodeToCluster$($cluster.Name)" {
                        Name                          = $cluster.Name
                        DomainAdministratorCredential = $domainAdministrator
                        StaticIPAddress               = $clusterStaticAddress.CIDR
                        IgnoreNetwork                 = $clusterIgnoreNetwork.CIDR
                        # If RSAT-Clustering is not installed the cluster can not be created
                        DependsOn                     = '[WindowsFeature]AddWindowsFeatureFailoverClustering', '[WindowsFeature]AddWindowsFeatureRSATClustering', '[Computer]RenameComputer'
                    }
                } else {
                    WaitForAny "WaitForCluster$($cluster.Name)" {
                        ResourceName = "[xCluster]AddNodeToCluster$($cluster.Name)"
                        NodeName = ($clusterOrder.$($cluster.Name))[-1]

                        # 30 Minutes
                        RetryIntervalSec = 15
                        RetryCount       = 120

                        # If RSAT-Clustering is not installed the cluster can not be created
                        DependsOn        = '[WindowsFeature]AddWindowsFeatureFailoverClustering', '[WindowsFeature]AddWindowsFeatureRSATClustering', '[Computer]RenameComputer'
                    }

                    xCluster "AddNodeToCluster$($cluster.Name)" {
                        Name                          = $cluster.Name
                        DomainAdministratorCredential = $domainAdministrator
                        StaticIPAddress               = $clusterStaticAddress.CIDR
                        IgnoreNetwork                 = $clusterIgnoreNetwork.CIDR
                        DependsOn                     = "[WaitForAny]WaitForCluster$($cluster.Name)"
                    }

                    $clusterOrder.$($cluster.Name) += [array] $node.NodeName

                    Script "AddStaticIPToCluster$($cluster.Name)" {
                        GetScript = {
                        }
                        TestScript = {
                            if (Get-ClusterResource | Where-Object { $_.ResourceType -eq 'IP Address' } | Get-ClusterParameter -Name Address | Where-Object { $_.Value -eq $using:clusterStaticAddress.IPAddress }) {
                                $true
                            } else {
                                $false
                            }
                        }
                        SetScript = {
                            $resourceName = "IP Address $($using:clusterStaticAddress.IPAddress)"
                            Get-Cluster | Add-ClusterResource -Name $resourceName -Group 'Cluster Group' -ResourceType 'IP Address'
                            Get-ClusterResource -Name $resourceName | Set-ClusterParameter -Multiple @{ Address = $clusterStaticAddress.IPAddress; Network = $using:clusterStaticAddress.Name; SubnetMask = $using:clusterStaticAddress.SubnetMask; }
                            $dependencyExpression = (Get-Cluster | Get-ClusterResourceDependency -Resource 'Cluster Name').DependencyExpression
                            if ($dependencyExpression -match '^\((.*)\)$') {
                                $dependencyExpression = $Matches[1] + " or [$resourceName]"
                            } else {
                                $dependencyExpression = $dependencyExpression + " or [$resourceName]"
                            }
                            Get-Cluster | Set-ClusterResourceDependency -Resource 'Cluster Name' -Dependency $dependencyExpression
                            # Without this, it won't start automatically on first try
                            (Get-Cluster | Get-ClusterResource -Name $resourceName).PersistentState = 1
                        }

                        DependsOn = "[xClusterNetwork]RenameClusterNetwork$($cluster.Name)Client", "[xClusterNetwork]RenameClusterNetwork$($cluster.Name)Heartbeat"
                    }
                }

                xClusterNetwork "RenameClusterNetwork$($cluster.Name)Client" {
                    Address = $clusterStaticAddress.NetworkID
                    AddressMask = $clusterStaticAddress.SubnetMask
                    Name = $clusterStaticAddress.Name
                    Role = 3 # Heartbeat and Client

                    DependsOn = "[xCluster]AddNodeToCluster$($cluster.Name)"
                }

                xClusterNetwork "RenameClusterNetwork$($cluster.Name)Heartbeat" {
                    Address = $clusterIgnoreNetwork.NetworkID
                    AddressMask = $clusterIgnoreNetwork.SubnetMask
                    Name = $clusterIgnoreNetwork.Name
                    Role = 1 # Heartbeat Only

                    DependsOn = "[xCluster]AddNodeToCluster$($cluster.Name)"
                }
            }

            if ($node.Role.ContainsKey('SqlServer')) {
                SqlSetup 'InstallSQLServer' {
                    InstanceName = $node.Role.SqlServer.InstanceName
                    Action = 'Install'
                    SourcePath = $node.Role.SqlServer.SourcePath
                    Features = $node.Role.SqlServer.Features
                    SQLSvcAccount = $sqlEngineServiceC1
                    SQLSysAdminAccounts = $localAdministrator.UserName
                    UpdateEnabled = 'False'

                    DependsOn = "[xCluster]AddNodeToCluster$($cluster.Name)"
                }

                SqlWindowsFirewall 'AddFirewallRuleSQL' {
                    InstanceName = $node.Role.SqlServer.InstanceName
                    SourcePath = $node.Role.SqlServer.SourcePath
                    Features = $node.Role.SqlServer.Features
                    Ensure = 'Present'

                    DependsOn = '[SqlSetup]InstallSQLServer'
                }

                SqlAlwaysOnService 'EnableAlwaysOn' {
                    ServerName = $node.NodeName
                    InstanceName = $node.Role.SqlServer.InstanceName
                    Ensure = 'Present'

                    DependsOn = '[SqlWindowsFirewall]AddFirewallRuleSQL'
                }

                SqlServerEndpoint 'CreateHadrEndpoint'
                {
                    EndPointName         = 'HADR'
                    Ensure               = 'Present'
                    Port                 = 5022
                    ServerName           = $node.NodeName
                    InstanceName         = $node.Role.SqlServer.InstanceName

                    DependsOn = '[SqlAlwaysOnService]EnableAlwaysOn'
                }

                SqlServerPermission 'AddPermissionsForAGMembership'
                {
                    Ensure               = 'Present'
                    ServerName           = $node.NodeName
                    InstanceName         = $node.Role.SqlServer.InstanceName
                    Principal            = 'NT AUTHORITY\SYSTEM'
                    Permission           = 'AlterAnyAvailabilityGroup', 'ViewServerState'

                    PsDscRunAsCredential = $localAdministrator
                }

                if ($node.Role.ContainsKey("AvailabilityGroup")) {
                    if (!$availabilityReplicaOrder.ContainsKey($node.Role.AvailabilityGroup.Name)) {
                        $availabilityReplicaOrder.$($node.Role.AvailabilityGroup.Name) = [array] $node.NodeName

                        # Create the availability group on the instance tagged as the primary replica
                        SqlAG "CreateAvailabilityGroup$($node.Role.AvailabilityGroup.Name)" {
                            Ensure               = 'Present'
                            Name                 = $node.Role.AvailabilityGroup.Name
                            InstanceName         = $node.Role.SQLServer.InstanceName
                            ServerName           = $node.NodeName
                            DependsOn            = '[SqlServerPermission]AddPermissionsForAGMembership'
                            PsDscRunAsCredential = $localAdministrator
                        }

                        SqlDatabase "CreateDatabaseDummy$($node.Role.AvailabilityGroup.Name)" {
                            Ensure       = 'Present'
                            ServerName   = $node.NodeName
                            InstanceName = $node.Role.SQLServer.InstanceName
                            Name         = "Dummy$($node.Role.AvailabilityGroup.Name)"
                            PsDscRunAsCredential = $localAdministrator
                            DependsOn = '[SqlSetup]InstallSQLServer'
                        }

                        SqlDatabaseRecoveryModel "SetDatabaseRecoveryModelDummy$($node.Role.AvailabilityGroup.Name)" {
                            Name         = "Dummy$($node.Role.AvailabilityGroup.Name)"
                            RecoveryModel        = 'Full'
                            ServerName           = $node.NodeName
                            InstanceName         = $node.Role.SQLServer.InstanceName
                            PsDscRunAsCredential = $localAdministrator
                            DependsOn = "[SqlDatabase]CreateDatabaseDummy$($node.Role.AvailabilityGroup.Name)"
                        }

                        # This really needs wait for all replicas to be added
                        SqlAGDatabase "AddDatabaseTo$($node.Role.AvailabilityGroup.Name)"
                        {
                            AvailabilityGroupName   = $node.Role.AvailabilityGroup.Name
                            BackupPath              = '\\CHDC1\Temp'
                            DatabaseName            = "Dummy$($node.Role.AvailabilityGroup.Name)"
                            ServerName              = $node.NodeName
                            InstanceName            = $node.Role.SQLServer.InstanceName
                            Ensure                  = 'Present'
                            PsDscRunAsCredential    = $localAdministrator
                            DependsOn = "[SqlDatabaseRecoveryModel]SetDatabaseRecoveryModelDummy$($node.Role.AvailabilityGroup.Name)"
                        }
                    } else {
                        SqlWaitForAG "WaitFor$($node.Role.AvailabilityGroup.Name)" {
                            Name                 = $node.Role.AvailabilityGroup.Name
                            RetryIntervalSec     = 15
                            RetryCount           = 120

                            PsDscRunAsCredential = $localAdministrator
                        }

                        SqlAGReplica "AddReplicaToAvailabilityGroup$($node.Role.AvailabilityGroup.Name)" {
                            Ensure               = 'Present'
                            AvailabilityGroupName = $node.Role.AvailabilityGroup.Name

                            Name                 = $node.NodeName # X\X format
                            ServerName           = $node.NodeName
                            InstanceName         = $node.Role.SQLServer.InstanceName
                            PrimaryReplicaServerName   = $availabilityReplicaOrder.$($node.Role.AvailabilityGroup.Name)[0]
                            PrimaryReplicaInstanceName = $node.Role.SQLServer.InstanceName
                            DependsOn            = '[SqlServerPermission]AddPermissionsForAGMembership', "[SqlWaitForAG]WaitFor$($node.Role.AvailabilityGroup.Name)"
                            PsDscRunAsCredential = $localAdministrator
                        }
                    }

                    # Interesting if this works on all nodes
                    SqlAGListener "CreateListener$($node.Role.AvailabilityGroup.ListenerName)" {
                        Ensure               = 'Present'
                        ServerName           = $node.NodeName
                        InstanceName         = $node.Role.SQLServer.InstanceName
                        AvailabilityGroup    = $node.Role.AvailabilityGroup.Name
                        Name                 = $node.Role.AvailabilityGroup.ListenerName
                        IpAddress            = $node.Role.AvailabilityGroup.IPAddress
                        Port                 = 1433

                        PsDscRunAsCredential = $localAdministrator
                    }



                }
            }
        }
    }
}
