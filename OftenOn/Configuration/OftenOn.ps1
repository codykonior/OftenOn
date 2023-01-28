Configuration OftenOn {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
    param (
        $CustomResourcePath
    )

    #region Resources
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.5.0
    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.2.0
    Import-DscResource -ModuleName DnsServerDsc -ModuleVersion 3.0.0
    Import-DscResource -ModuleName xWindowsUpdate -ModuleVersion 2.8.0.0
    # These have fixes in the dev branches but the changes are not to parameters so any version here will do
    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 16.0.0
    Import-DscResource -ModuleName FailoverClusterDsc -ModuleVersion 2.1.0
    # This is a composite resource and doesn't need to be on the destination machine
    Import-DscResource -ModuleName OftenOn -ModuleVersion 1.1.16
    #endregion

    $domainController = @{}
    $clusterOrder = @{}

    $availabilityReplicaOrder = @{}
    $availabilityGroups = $AllNodes | Where-Object { $_.Role.ContainsKey('AvailabilityGroup') } | Group-Object { $_.Role.AvailabilityGroup.Name }
    foreach ($availabilityGroup in $availabilityGroups) {
        $availabilityReplicaOrder.($availabilityGroup.Name) = [array] $availabilityGroup.Group.NodeName
        $availabilityReplicaOrder.($availabilityGroup.Name) += $availabilityGroup.Group.NodeName
    }

    Node $AllNodes.NodeName {
        # When building the domain the UserName is ignored. But the domain part of the username is required to use the credential to add computers to the domain.
        $domainAdministrator = New-Object System.Management.Automation.PSCredential("$($node.DomainName)\Administrator", ('Admin2023!' | ConvertTo-SecureString -AsPlainText -Force))
        $safemodeAdministrator = New-Object System.Management.Automation.PSCredential('Administrator', ('Safe2023!' | ConvertTo-SecureString -AsPlainText -Force))
        # These accounts must have the domain part stripped when they are created, because they're added by the ActiveDirectory module @oftenon.com
        $localAdministrator = New-Object System.Management.Automation.PSCredential("$($node.DomainName)\LocalAdministrator", ('Local2023!' | ConvertTo-SecureString -AsPlainText -Force))
        $sqlEngineService = New-Object System.Management.Automation.PSCredential("$($node.DomainName)\SQLEngineService", ('Engine2023!' | ConvertTo-SecureString -AsPlainText -Force))
        # This isn't a domain login
        $systemAdministrator = New-Object System.Management.Automation.PSCredential("sa", ('System2023!' | ConvertTo-SecureString -AsPlainText -Force))

        #region Local Configuration Manager settings
        LocalConfigurationManager {
            RebootNodeIfNeeded             = $true
            AllowModuleOverwrite           = $true
            CertificateID                  = $node.Thumbprint

            # Stops caching of modules so things move faster
            DebugMode                      = "ForceModuleImport"

            # This retries the configuration every 15 minutes (the minimum) until it has entirely passed once
            ConfigurationMode              = 'ApplyOnly'
            ConfigurationModeFrequencyMins = 15
        }
        #endregion

        ooDscLog 'EnableDscLog' {
        }

        TimeZone 'SetTimeZone' {
            IsSingleInstance = 'Yes'
            TimeZone         = (Get-TimeZone).StandardName

            DependsOn        = '[ooDscLog]EnableDscLog'
        }

        ooRegistry 'SetRegistry' {
            DependsOn = '[TimeZone]SetTimeZone'
        }

        ooRemoteDesktop 'EnableRemoteDesktop' {
            DependsOn = '[TimeZone]SetTimeZone'
        }

        ooTemp 'CreateTempDirectory' {
            DependsOn = '[TimeZone]SetTimeZone'
        }

        ooNetwork 'RenameNetwork' {
            Node      = $node
            DependsOn = '[TimeZone]SetTimeZone'
        }

        #region Add basic Windows features depending on Role
        $windowsFeatures = 'RSAT-AD-Tools', 'RSAT-AD-PowerShell', 'RSAT-Clustering', 'RSAT-Clustering-CmdInterface', 'RSAT-DNS-Server', 'RSAT-RemoteAccess'
        if ($node.ContainsKey('Role')) {
            if ($node.Role.ContainsKey('DomainController')) {
                $windowsFeatures += 'AD-Domain-Services', 'DNS'
            }
            if ($node.Role.ContainsKey('Cluster')) {
                $windowsFeatures += 'Failover-Clustering'
            }
            if ($node.Role.ContainsKey('Router')) {
                $windowsFeatures += 'Routing'
            }
        }
        WindowsFeatureSet "All" {
            Name      = $windowsFeatures
            Ensure    = 'Present'

            DependsOn = '[TimeZone]SetTimeZone'
        }
        #endregion
        #       ^-- DependsOn 'WindowsFeatureSet[All]'

        # More complex dependency chains start here

        if ($node.ContainsKey('Role')) {
            if ($node.Role.ContainsKey('Router')) {
                ooRouter 'EnableRouter' {
                    DependsOn = "[ooNetwork]RenameNetwork"
                }
            }
        }

        #region Active Directory
        if ($node.ContainsKey('Role')) {
            if ($node.Role.ContainsKey('DomainController')) {
                $domainController.$($node.DomainName) = $node.NodeName

                # These execute in sequence

                #region Rename the computer
                Computer 'Rename' {
                    Name      = $node.NodeName
                    DependsOn = "[ooNetwork]RenameNetwork"
                }
                #endregion

                #region Create Domain
                ADDomain 'Create' {
                    DomainName                    = $node.FullyQualifiedDomainName
                    Credential = $domainAdministrator
                    SafemodeAdministratorPassword = $safemodeAdministrator

                    DependsOn                     = '[WindowsFeatureSet]All'
                }

                #region Set Time Sync (required for Windows Server 2016 Hyper-V clients to work)
                ooTime 'SetTime' {
                    DependsOn = '[ADDomain]Create'
                }
                #endregion

                #region Create an AD lookup, just makes nslookup work nicer
                # This should really be done for all networks and computers but...
                DnsServerADZone 'AddReverseZone' {
                    Name             = '0.0.10.in-addr.arpa'
                    DynamicUpdate    = 'Secure'
                    ReplicationScope = 'Forest'

                    Ensure           = 'Present'
                    DependsOn        = '[ADDomain]Create'
                }

                DnsRecordPtr 'AddReverseZoneLookup' {
                    ZoneName      = '0.0.10.in-addr.arpa'
                    IPAddress = '10.0.0.1'
                    Name = 'CHDC01.oftenon.com'

                    Ensure    = 'Present'
                    DependsOn = '[DnsServerADZone]AddReverseZone'
                }
                #endregion

                # If ADWS isn't started some resources will fail to run (even though they shouldn't)
                Service 'EnableADService' {
                    Name        = 'ADWS'
                    StartupType = 'Automatic'
                    Ensure      = 'Present'
                    State       = 'Running'

                    DependsOn   = '[ADDomain]Create'
                }
                #endregion

                #region Create Users/Groups
                ADUser 'CreateUserSQLEngineService' {
                    # Make sure the UserName is a straight username because the DSC adds @DomainName onto the end.
                    DomainName  = $node.FullyQualifiedDomainName
                    UserName    = ($sqlEngineService.UserName -split '\\')[1]
                    Description = 'SQL Engine Service'
                    Password    = $sqlEngineService
                    Ensure      = 'Present'
                    DependsOn   = '[ADDomain]Create'
                }

                ADUser "CreateLocalAdministrator" {
                    DomainName  = $node.FullyQualifiedDomainName
                    UserName    = ($localAdministrator.UserName -split '\\')[1]
                    Description = 'Local Administrator'
                    Password    = $localAdministrator
                    Ensure      = 'Present'
                    DependsOn   = '[ADDomain]Create'
                }

                Group 'AddLocalAdministratorToAdministratorsGroup' {
                    GroupName        = 'Administrators'
                    Ensure           = 'Present'
                    MembersToInclude = $localAdministrator.UserName
                    DependsOn        = '[ADUser]CreateLocalAdministrator'
                }
                #endregion

                #region Create a Resources and Temp share on the Domain Controller for other VMs to use
                SmbShare 'CreateResources' {
                    Name       = 'Resources'
                    Ensure     = 'Present'

                    Path       = 'C:\Resources'
                    ReadAccess = 'Everyone'

                    DependsOn  = '[ADDomain]Create'
                }

                SmbShare 'CreateTemp' {
                    Name       = 'Temp'
                    Ensure     = 'Present'

                    Path       = 'C:\Temp'
                    FullAccess = 'Everyone'

                    DependsOn  = '[ADDomain]Create'
                }
                #endregion

                # Use CloudFlare to service DNS requests as we don't know what
                # Hyper-V would use otherwise
                DnsServerForwarder "WAN Forwarder" {
                    IsSingleInstance = "Yes";
                    IPAddresses      = "1.1.1.1";
                    DependsOn        = '[SmbShare]CreateTemp';
                }
            } elseif ($node.Role.ContainsKey('DomainMember')) {
                #region Wait for Active Directory
                # If you don't have a WAN link, the fully qualified domain name works here
                # and in the computer rename. If you do have a WAN link and disable forwarding
                # then you MUST use the short domain name otherwise the domain isn't found.
                # However it will then break. So not being able to use a full one indicates
                # another issue in your setup.
                WaitForADDomain 'Create' {
                    DomainName           = $node.FullyQualifiedDomainName
                    Credential = $domainAdministrator
                    WaitForValidCredentials = $true

                    DependsOn            = "[ooNetwork]RenameNetwork"
                }
                #endregion

                #region Rename computer (while joining to Active Directory)
                Computer 'Rename' {
                    Name       = $node.NodeName
                    DomainName = $node.FullyQualifiedDomainName
                    Credential = $domainAdministrator
                    DependsOn  = '[WaitForADDomain]Create'
                }
                #endregion

                #region Add LocalAdministrator to Administrators Group
                WaitForAll "CreateLocalAdministrator" {
                    ResourceName         = '[ADUser]CreateLocalAdministrator'
                    NodeName             = $domainController.$($node.DomainName)

                    # Otherwise you'll wait for life
                    PsDscRunAsCredential = $domainAdministrator

                    # 30 Minutes
                    RetryIntervalSec     = 15
                    RetryCount           = 120

                    DependsOn            = '[Computer]Rename'
                }

                Group 'AddLocalAdministratorToAdministratorsGroup' {
                    GroupName        = 'Administrators'
                    Ensure           = 'Present'
                    MembersToInclude = $localAdministrator.UserName
                    DependsOn        = '[WaitForAll]CreateLocalAdministrator'
                }
                #endregion
            }
        }
        #endregion

        #region Clustering
        if ($node.ContainsKey("Role")) {
            if ($node.Role.ContainsKey('Cluster')) {
                $cluster = $node.Role.Cluster
                $clusterStaticAddress = $cluster.StaticAddress
                $clusterIgnoreNetwork = $cluster.IgnoreNetwork

                if (!$clusterOrder.ContainsKey($cluster.Name)) {
                    $clusterOrder.$($cluster.Name) = [array] $node.NodeName
                    Cluster "AddNodeToCluster$($cluster.Name)" {
                        Name                          = $cluster.Name
                        DomainAdministratorCredential = $domainAdministrator
                        StaticIPAddress               = $clusterStaticAddress.CIDR
                        IgnoreNetwork                 = $clusterIgnoreNetwork.CIDR
                        # If RSAT-Clustering is not installed the cluster can not be created
                        DependsOn                     = '[WindowsFeatureSet]All', '[Computer]Rename'
                    }
                } else {
                    WaitForAll "WaitForCluster$($cluster.Name)" {
                        ResourceName         = "[Cluster]AddNodeToCluster$($cluster.Name)"
                        NodeName             = ($clusterOrder.$($cluster.Name))[-1]

                        # 30 Minutes
                        RetryIntervalSec     = 15
                        RetryCount           = 120

                        PsDscRunAsCredential = $domainAdministrator
                        # If RSAT-Clustering is not installed the cluster can not be created
                        DependsOn            = '[WindowsFeatureSet]All', '[Computer]Rename'
                    }

                    Cluster "AddNodeToCluster$($cluster.Name)" {
                        Name                          = $cluster.Name
                        DomainAdministratorCredential = $domainAdministrator
                        StaticIPAddress               = $clusterStaticAddress.CIDR
                        IgnoreNetwork                 = $clusterIgnoreNetwork.CIDR
                        DependsOn                     = "[WaitForAll]WaitForCluster$($cluster.Name)"
                    }

                    $clusterOrder.$($cluster.Name) += [array] $node.NodeName

                    Script "AddStaticIPToCluster$($cluster.Name)" {
                        GetScript  = {
                            if (Get-ClusterResource | Where-Object { $_.ResourceType -eq 'IP Address' } | Get-ClusterParameter -Name Address | Where-Object { $_.Value -eq $using:clusterStaticAddress.IPAddress }) {
                                @{ Result = "true"; }
                            } else {
                                @{ Result = "false"; }
                            }
                        }
                        TestScript = {
                            if (Get-ClusterResource | Where-Object { $_.ResourceType -eq 'IP Address' } | Get-ClusterParameter -Name Address | Where-Object { $_.Value -eq $using:clusterStaticAddress.IPAddress }) {
                                $true
                            } else {
                                $false
                            }
                        }
                        SetScript  = {
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

                        DependsOn  = "[ClusterNetwork]RenameClusterNetwork$($cluster.Name)Client", "[ClusterNetwork]RenameClusterNetwork$($cluster.Name)Heartbeat"
                    }
                }

                ClusterNetwork "RenameClusterNetwork$($cluster.Name)Client" {
                    Address     = $clusterStaticAddress.NetworkID
                    AddressMask = $clusterStaticAddress.SubnetMask
                    Name        = $clusterStaticAddress.Name
                    Role        = 3 # Heartbeat and Client

                    DependsOn   = "[Cluster]AddNodeToCluster$($cluster.Name)"
                }

                ClusterNetwork "RenameClusterNetwork$($cluster.Name)Heartbeat" {
                    Address     = $clusterIgnoreNetwork.NetworkID
                    AddressMask = $clusterIgnoreNetwork.SubnetMask
                    Name        = $clusterIgnoreNetwork.Name
                    Role        = 1 # Heartbeat Only

                    DependsOn   = "[Cluster]AddNodeToCluster$($cluster.Name)"
                }
            }
        }
        #endregion

        #region SQL Server
        if ($node.ContainsKey('Role')) {
            if ($node.Role.ContainsKey('SqlServer')) {
                SqlSetup 'InstallSQLServer' {
                    InstanceName        = $node.Role.SqlServer.InstanceName
                    Action              = 'Install'
                    SourcePath          = $node.Role.SqlServer.SourcePath
                    Features            = $node.Role.SqlServer.Features
                    SecurityMode        = 'Sql'
                    SAPwd               = $systemAdministrator
                    SQLSvcAccount       = $sqlEngineService
                    SQLSysAdminAccounts = $localAdministrator.UserName
                    UpdateEnabled       = 'True'
                    UpdateSource        = '\\CHDC01\Resources'
                    DependsOn           = "[Cluster]AddNodeToCluster$($cluster.Name)"
                }

                SqlWindowsFirewall 'AddFirewallRuleSQL' {
                    InstanceName = $node.Role.SqlServer.InstanceName
                    SourcePath   = $node.Role.SqlServer.SourcePath
                    Features     = $node.Role.SqlServer.Features
                    Ensure       = 'Present'

                    DependsOn    = '[SqlSetup]InstallSQLServer'
                }

                SqlAlwaysOnService 'EnableAlwaysOn' {
                    ServerName   = $node.NodeName
                    InstanceName = $node.Role.SqlServer.InstanceName
                    Ensure       = 'Present'

                    DependsOn    = '[SqlWindowsFirewall]AddFirewallRuleSQL'
                }

                SqlLogin 'CreateLoginForAG' {
                    Ensure               = 'Present'
                    ServerName           = $node.NodeName
                    InstanceName         = $node.Role.SqlServer.InstanceName
                    Name                 = $sqlEngineService.UserName

                    DependsOn            = '[SqlSetup]InstallSQLServer'
                    PsDscRunAsCredential = $localAdministrator
                }

                SqlEndpoint 'CreateHadrEndpoint' {
                    EndPointName = 'Hadr_endpoint' # For some reason the Examples use HADR; but this is what the wizard uses
                    Ensure       = 'Present'
                    EndpointType = 'DatabaseMirroring'
                    Port         = 5022
                    ServerName   = $node.NodeName
                    InstanceName = $node.Role.SqlServer.InstanceName

                    DependsOn    = '[SqlAlwaysOnService]EnableAlwaysOn'
                }

                SqlEndpointPermission 'AddLoginForAGEndpointPermission' {
                    Ensure               = 'Present'
                    ServerName           = $node.NodeName
                    InstanceName         = $node.Role.SqlServer.InstanceName
                    Name                 = 'Hadr_endpoint'
                    Principal            = $sqlEngineService.UserName
                    Permission           = 'CONNECT'

                    PsDscRunAsCredential = $localAdministrator
                    DependsOn            = '[SqlEndpoint]CreateHadrEndpoint', '[SqlLogin]CreateLoginForAG'
                }

                SqlPermission 'AddPermissionsForAGMembership' {
                    ServerName           = $node.NodeName
                    InstanceName         = $node.Role.SqlServer.InstanceName
                    Name            = 'NT AUTHORITY\SYSTEM'
                    Permission           = @(
                            ServerPermission
                            {
                                State      = 'Grant'
                                Permission = @('AlterAnyAvailabilityGroup', 'ViewServerState')
                            }
                            ServerPermission
                            {
                                State      = 'GrantWithGrant'
                                Permission = @()
                            }
                            ServerPermission
                            {
                                State      = 'Deny'
                                Permission = @()
                            }
                        )
                    DependsOn            = '[SqlSetup]InstallSQLServer'
                    Credential = $localAdministrator
                }

                if ($node.Role.ContainsKey("AvailabilityGroup")) {
                    $availabilityGroupReplicaOrder = $availabilityReplicaOrder.($node.Role.AvailabilityGroup.Name)

                    if ($availabilityGroupReplicaOrder[0] -eq $node.NodeName) {
                        # Create the availability group on the instance tagged as the primary replica
                        SqlAG "CreateAvailabilityGroup$($node.Role.AvailabilityGroup.Name)" {
                            Ensure                        = 'Present'
                            Name                          = $node.Role.AvailabilityGroup.Name
                            InstanceName                  = $node.Role.SQLServer.InstanceName
                            ServerName                    = $node.NodeName
                            AvailabilityMode              = 'SynchronousCommit'
                            FailoverMode                  = 'Automatic'
                            ConnectionModeInPrimaryRole   = 'AllowAllConnections'
                            ConnectionModeInSecondaryRole = 'AllowAllConnections'

                            PsDscRunAsCredential          = $localAdministrator
                            DependsOn                     = '[SqlPermission]AddPermissionsForAGMembership'
                        }

                        SqlAGReplica "CreateAvailabilityGroup$($node.Role.AvailabilityGroup.Name)ReplicaSettings" {
                            Ensure                       = 'Present'
                            AvailabilityGroupName        = $node.Role.AvailabilityGroup.Name

                            Name                         = $node.NodeName # X\X format
                            ServerName                   = $node.NodeName
                            InstanceName                 = $node.Role.SQLServer.InstanceName
                            PrimaryReplicaServerName     = $availabilityReplicaOrder.$($node.Role.AvailabilityGroup.Name)[0]
                            PrimaryReplicaInstanceName   = $node.Role.SQLServer.InstanceName

                            # AvailabilityMode           = $node.Role.AvailabilityGroup.AvailabilityMode
                            # FailoverMode               = $node.Role.AvailabilityGroup.FailoverMode
                            # ConnectionModeInPrimaryRole   = 'AllowAllConnections'
                            # ConnectionModeInSecondaryRole = 'AllowAllConnections'

                            ReadOnlyRoutingConnectionUrl = "tcp://$($node.NodeName):1433"

                            DependsOn                    = "[SqlAG]CreateAvailabilityGroup$($node.Role.AvailabilityGroup.Name)"
                            PsDscRunAsCredential         = $localAdministrator
                        }

                        $completeListenerList = $AllNodes | Where-Object { $_.ContainsKey('Role') -and $_.Role.ContainsKey('AvailabilityGroup') -and $_.Role.AvailabilityGroup.Name -eq $node.Role.AvailabilityGroup.Name } | ForEach-Object { $_.Role.AvailabilityGroup.IPAddress } | Select-Object -Unique

                        <#
                            If you try to create a listener with an IP but not the IP on the primary, it will fail.

                            None of the IP addresses configured for the availability group listener can be hosted by the server 'SEC1N1'. Either
                            configure a public cluster network on which one of the specified IP addresses can be hosted, or add another listener
                            IP address which can be hosted on a public cluster network for this server.
                                + CategoryInfo          : InvalidOperation: (:) [], CimException
                                + FullyQualifiedErrorId : ExecutionFailed,Microsoft.SqlServer.Management.PowerShell.Hadr.NewSqlAvailabilityGroupLi
                            stenerCommand
                                + PSComputerName        : DAC1N1

                            If you have a listener with an IP:
                                If you try to add another server you need to add it on one side, add the listener
                                IP, and then join on the secondary, otherwise you'll get an error trying to join the secondary too early because
                                there's no listener IP. DSC isn't this fine-grained.
                            If you have a listener defined with all IPs:
                                You can join immediately.
                            If you have no listener, you can join easily.
                        #>
                        SqlAGListener "CreateListener$($node.Role.AvailabilityGroup.ListenerName)" {
                            Ensure               = 'Present'
                            ServerName           = $node.NodeName
                            InstanceName         = $node.Role.SQLServer.InstanceName
                            AvailabilityGroup    = $node.Role.AvailabilityGroup.Name
                            Name                 = $node.Role.AvailabilityGroup.ListenerName
                            IpAddress            = $completeListenerList
                            Port                 = 1433

                            PsDscRunAsCredential = $localAdministrator
                            DependsOn            = "[SqlAg]CreateAvailabilityGroup$($node.Role.AvailabilityGroup.Name)"
                        }

                        1..4 | ForEach-Object {
                            SqlDatabase "CreateDatabase$($node.Role.AvailabilityGroup.Name)DB$_" {
                                Ensure               = 'Present'
                                ServerName           = $node.NodeName
                                InstanceName         = $node.Role.SQLServer.InstanceName
                                Name                 = "$($node.Role.AvailabilityGroup.Name)DB$_"
                                RecoveryModel = 'Full'
                                PsDscRunAsCredential = $localAdministrator
                                DependsOn            = '[SqlSetup]InstallSQLServer'
                            }
                        }

                        $completeReplicaList = $AllNodes | Where-Object { $_.NodeName -ne $node.NodeName -and $_.ContainsKey('Role') -and $_.Role.ContainsKey('AvailabilityGroup') -and $_.Role.AvailabilityGroup.Name -eq $node.Role.AvailabilityGroup.Name } | ForEach-Object { $_.NodeName }

                        # This won't give you an error if you forget the resource [] part of the ResourceName!
                        WaitForAll 'WaitForAllAGReplicas' {
                            ResourceName         = "[SqlAGReplica]AddReplicaToAvailabilityGroup$($node.Role.AvailabilityGroup.Name)"
                            NodeName             = $completeReplicaList
                            RetryCount           = 120
                            RetryIntervalSec     = 15

                            PsDscRunAsCredential = $localAdministrator
                            DependsOn            = "[SqlDatabase]CreateDatabase$($node.Role.AvailabilityGroup.Name)DB4"
                        }

                        # This really needs wait for all replicas to be added
                        # This will give an error if you use MatchDatabaseOwner on SQL 2012
                        $databaseNames = 1..4 | ForEach-Object {
                            "$($node.Role.AvailabilityGroup.Name)DB$_"
                        }

                        SqlAGDatabase "Add$($node.Role.AvailabilityGroup.Name)Database" {
                            AvailabilityGroupName = $node.Role.AvailabilityGroup.Name
                            BackupPath            = '\\CHDC01\Temp' # TODO: Remove this
                            DatabaseName          = $databaseNames
                            ServerName            = $node.NodeName
                            InstanceName          = $node.Role.SQLServer.InstanceName
                            Ensure                = 'Present'
                            PsDscRunAsCredential  = $localAdministrator
                            # MatchDatabaseOwner = $true # EXECUTE AS
                            DependsOn             = '[WaitForAll]WaitForAllAGReplicas'
                        }
                    } else {
                        WaitForAll "WaitFor$($node.Role.AvailabilityGroup.ListenerName)" {
                            ResourceName         = "[SqlAGListener]CreateListener$($node.Role.AvailabilityGroup.ListenerName)"
                            NodeName             = $availabilityReplicaOrder.$($node.Role.AvailabilityGroup.Name)[0]
                            RetryIntervalSec     = 15
                            RetryCount           = 120

                            PsDscRunAsCredential = $localAdministrator
                        }

                        SqlAGReplica "AddReplicaToAvailabilityGroup$($node.Role.AvailabilityGroup.Name)" {
                            Ensure                        = 'Present'
                            AvailabilityGroupName         = $node.Role.AvailabilityGroup.Name

                            Name                          = $node.NodeName # X\X format
                            ServerName                    = $node.NodeName
                            InstanceName                  = $node.Role.SQLServer.InstanceName
                            PrimaryReplicaServerName      = $availabilityReplicaOrder.$($node.Role.AvailabilityGroup.Name)[0]
                            PrimaryReplicaInstanceName    = $node.Role.SQLServer.InstanceName
                            AvailabilityMode              = $node.Role.AvailabilityGroup.AvailabilityMode
                            FailoverMode                  = $node.Role.AvailabilityGroup.FailoverMode
                            ConnectionModeInPrimaryRole   = 'AllowAllConnections'
                            ConnectionModeInSecondaryRole = 'AllowAllConnections'
                            ReadOnlyRoutingConnectionUrl  = "tcp://$($node.NodeName):1433"

                            DependsOn                     = "[WaitForAll]WaitFor$($node.Role.AvailabilityGroup.ListenerName)"
                            PsDscRunAsCredential          = $localAdministrator
                        }
                    }

                }
            }
        }
        #endregion

        $resourceLocation = "\\$($domainController.$($node.DomainName))\Resources"

        #region Workstation
        if ($node.ContainsKey('Role')) {
            if ($node.Role.ContainsKey('Workstation')) {
                ooNetFramework 'Install472' {
                    ResourceLocation = "$resourceLocation\ndp472-kb4054530-x86-x64-allos-enu.exe"
                }

                ooManagementStudio 'InstallManagementStudio' {
                    ResourceLocation = $resourceLocation
                    DependsOn        = '[ooNetFramework]Install472'
                }
            }
        }
    }
}
