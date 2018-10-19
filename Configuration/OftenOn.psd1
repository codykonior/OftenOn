@{
    AllNodes    = @(
        @{
            NodeName                          = '*'

            # VM settings
            Lability_ProcessorCount           = 2
            Lability_StartupMemory            = 2GB
            Lability_Media                    = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
            # Additional hard disk drive
            Lability_HardDiskDrive            = @(
                @{ Generation = 'VHDX'; MaximumSizeBytes = 127GB; }
            )
            Lability_GuestIntegrationServices = $true

            # Encryption information (the script will translate the environment variable)
            CertificateFile                   = '$env:ALLUSERSPROFILE\Lability\Certificates\LabClient.cer'
            Thumbprint                        = '5940D7352AB397BFB2F37856AA062BB471B43E5E'
            PSDscAllowDomainUser              = $true

            FullyQualifiedDomainName          = 'lab.com'
            DomainName                        = 'LAB'

            Role                              = @{ }
        }

        <#
            Configuration options

            NodeName                # String
            Network                 # Array of Hashtable
                                        The script will add arrays ..\Lability_SwitchName and ..\Lability_MACAddress
                                        SwitchName, NetAdapterName, IPAddress/CIDR, DnsServerAddress, DefaultGatewayAddress
            Role                    # Hashtable
                DomainController    # Empty Hashtable
                DomainMember        # Empty Hashtable
                Router              # Empty Hashtable
                Workstation         # Empty Hashtable
                Cluster             # Hashtable
                                        Name, StaticAddress/CIDR, IgnoreNetwork/CIDR (heartbeat adapter)
                SqlServer           # Hashtable
                                        InstanceName, Features, SourcePath
                AvailabilityGroup   # Hashtable
                                        Name, ListenerName, IPAddress/SubnetMask
        #>

        @{
            NodeName           = 'CHDC01'
            Lability_BootOrder = 1

            Network            = @(
                @{ SwitchName = 'CHICAGO'; NetAdapterName = 'CHICAGO'; IPAddress = '10.0.0.2/24'; DnsServerAddress = '127.0.0.1'; DefaultGatewayAddress = "10.0.0.1"; }
            )

            Role               = @{
                DomainController = @{ }
            }

            Lability_Resource  = @(
                'SQLServer2012', 'SQLServer2012SP4', 'SQLServer2012SP4GDR', 'SQLServer2012SP4GDRHotfix', 'SSMS179', 'NetFx472'
            )
        }

        @{
            NodeName           = 'ROUTER'
            Lability_BootOrder = 2

            Network            = @(
                @{ SwitchName = 'CHICAGO'; NetAdapterName = 'CHICAGO'; IPAddress = '10.0.0.1/24'; DnsServerAddress = '10.0.0.2'; }
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.1/24'; DnsServerAddress = '10.0.0.2'; }
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.1/24'; DnsServerAddress = '10.0.0.2'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.1/24'; } # DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.1/24'; } # DnsServerAddress = '127.0.0.1'; }

                # If the Dns isn't set then this will break all the other servers and stop them from querying, unless recursive DNS is disabled
                @{ SwitchName = 'Default Switch'; NetAdapterName = 'WAN'; } # DnsServerAddress = '127.0.0.1'; }
            )

            Role               = @{
                DomainMember = @{ }
                Router       = @{ }
            }
        }

        @{
            NodeName = 'CHWK01'

            Network  = @(
                @{ SwitchName = 'CHICAGO'; NetAdapterName = 'CHICAGO'; IPAddress = '10.0.0.3/24'; DnsServerAddress = '10.0.0.2'; DefaultGatewayAddress = '10.0.0.1'; }
            )

            Role     = @{
                DomainMember = @{ }
                Workstation  = @{ }
            }
        }

        @{
            NodeName           = 'SEC1N1'
            Lability_BootOrder = 3

            Network            = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.11/24'; DnsServerAddress = '10.0.0.2'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.11/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = "10.0.11.0/24"; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE,REPLICATION,FULLTEXT,SSMS,ADV_SSMS'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }

        @{
            NodeName           = 'SEC1N2'
            Lability_BootOrder = 3

            Network            = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.12/24'; DnsServerAddress = '10.0.0.2'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.12/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = "10.0.11.0/24"; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE,REPLICATION,FULLTEXT,SSMS,ADV_SSMS'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }

        @{
            NodeName           = 'SEC1N3'
            Lability_BootOrder = 3

            Network            = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.13/24'; DnsServerAddress = '10.0.0.2'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.13/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = "10.0.11.0/24"; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE,REPLICATION,FULLTEXT,SSMS,ADV_SSMS'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }

        @{
            NodeName           = 'DAC1N1'
            Lability_BootOrder = 4

            Network            = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.11/24'; DnsServerAddress = '10.0.0.2'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.11/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )

            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.2.21/24'; IgnoreNetwork = "10.0.12.0/24"; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE,REPLICATION,FULLTEXT,SSMS,ADV_SSMS'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.2.31/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }

        @{
            NodeName           = 'DAC1N2'
            Lability_BootOrder = 4

            Network            = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.12/24'; DnsServerAddress = '10.0.0.2'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.12/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )

            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.2.21/24'; IgnoreNetwork = "10.0.12.0/24"; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE,REPLICATION,FULLTEXT,SSMS,ADV_SSMS'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.2.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }
    )

    NonNodeData = @{
        Lability = @{
            # These resources are copied to the VM. If any are missing (except PSDesiredStateConfiguration) the first boot
            # will hang because DSC doesn't complete. Stopping and starting the VM will allow you to login to see the logs.
            DSCResource = @(
                @{ Name = 'ComputerManagementDsc'; RequiredVersion = '5.2.0.0'; }
                @{ Name = 'NetworkingDsc'; RequiredVersion = '6.1.0.0'; }
                @{ Name = 'xActiveDirectory'; RequiredVersion = '2.21.0.0'; }
                @{ Name = 'xDnsServer'; RequiredVersion = '1.11.0.0'; }
                @{ Name = 'xRemoteDesktopAdmin'; RequiredVersion = '1.1.0.0'; }
                @{ Name = 'xSmbShare'; RequiredVersion = '2.1.0.0'; }
                @{ Name = 'xSystemSecurity'; RequiredVersion = '1.4.0.0'; }
                @{ Name = 'xWinEventLog'; RequiredVersion = '1.2.0.0'; }
                @{ Name = 'xWindowsUpdate'; RequiredVersion = '2.7.0.0'; }

                # These have fixes in the dev branch, the first is absolutely required the others are just helpful
                @{ Name = 'xFailOverCluster'; RequiredVersion = '1.10.0.0'; Provider = 'GitHub'; Owner = "codykonior"; Branch = "dev"; }
                @{ Name = 'xPSDesiredStateConfiguration'; RequiredVersion = '8.4.0.0'; Provider = 'GitHub'; Owner = "codykonior"; Branch = "dev"; }
                @{ Name = 'SqlServerDsc'; RequiredVersion = '12.0.0.0'; Provider = 'GitHub'; Owner = "codykonior"; Branch = "readonlyrouting"; }
            )

            # These non-DSC modules are copied over to the VMs for general purpose use.
            Module      = @(
                @{ Name = 'Cim'; }
                @{ Name = 'DbData'; }
                @{ Name = 'Disposable'; }
                @{ Name = 'Error'; }
                @{ Name = 'Jojoba'; }
                @{ Name = 'ParseSql'; }
                @{ Name = 'Performance'; }
                @{ Name = 'PoshRSJob'; }
                @{ Name = 'SqlServer'; }
            )

            Network     = @(
                # You'll get this error if you change a switch type:
                # WARNING: [1:51:28 AM] DSC resource 'Set-VMTargetResource' failed with errror 'Sequence contains more than one element'.
                @{ Name = 'CHICAGO'; Type = 'Internal'; }
                @{ Name = 'SEATTLE'; Type = 'Internal'; }
                @{ Name = 'SEATTLE_HB'; Type = 'Private'; }
                @{ Name = 'DALLAS'; Type = 'Internal'; }
                @{ Name = 'DALLAS_HB'; Type = 'Private'; }
            )

            Media       = @(
                @{
                    # https://www.microsoft.com/en-in/evalcenter/evaluate-windows-server-2012
                    Id              = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
                    Filename        = '9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    Architecture    = 'x64'
                    Uri             = 'http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    Checksum        = '8503997171F731D9BD1CB0B0EDC31F3D'
                    Description     = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
                    MediaType       = 'ISO'
                    ImageName       = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
                    OperatingSystem = 'Windows'
                    Hotfixes        = @(
                        @{
                            # WMF 5.1 for Windows Server 2012
                            Id  = 'W2K12-KB3191565-x64.msu'
                            # Filename and Checksum are ignored
                            # Filename = 'W2K12-KB3191565-x64.msu'
                            # Checksum = 'E978C87841BAED49FB68206DF5E1DF9C'
                            Uri = 'https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/W2K12-KB3191565-x64.msu'
                        }
                        @{
                            # Failover Cluster Manager hotfix (without this, it will have errors when you update to certain .NET versions)
                            Id  = 'Windows8-RT-KB2803748-x64.msu'
                            Uri = 'https://download.microsoft.com/download/9/7/C/97CB21BF-FA24-46C7-BE44-88E7EE934841/Windows8-RT-KB2803748-x64.msu'
                        }
                    )
                    CustomData      = @{
                        CustomBootStrap        = @(
                            'Set-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force; #306'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                    }
                }
            )

            Resource    = @(
                @{
                    Id       = 'SQLServer2012'
                    Filename = 'SQLFULL_ENU.ISO'
                    Uri      = 'https://download.microsoft.com/download/4/C/7/4C7D40B9-BCF8-4F8A-9E76-06E9B92FE5AE/ENU/SQLFULL_ENU.iso'
                    Checksum = 'C44C1869A7657001250EF8FAD4F636D3'
                    Expand   = $true
                }
                @{
                    Id       = 'SQLServer2012SP4'
                    Filename = 'SQLServer2012SP4-KB4018073-x64-ENU.exe'
                    Uri      = 'https://download.microsoft.com/download/E/A/B/EABF1E75-54F0-42BB-B0EE-58E837B7A17F/SQLServer2012SP4-KB4018073-x64-ENU.exe'
                    Checksum = '5EFF56819F854866CCBAE26F0D091B63'
                }
                @{
                    Id       = 'SQLServer2012SP4GDR'
                    Filename = 'SQLServer2012-KB4057116-x64.exe'
                    Uri      = 'https://download.microsoft.com/download/F/6/1/F618E667-BA6E-4428-A36A-8B4F5190FCC8/SQLServer2012-KB4057116-x64.exe'
                    Checksum = 'FBD078835E0BDF5815271F848FD8CF58'
                }
                @{
                    Id       = 'SQLServer2012SP4GDRHotfix'
                    Filename = 'SQLServer2012-KB4091266-x64.exe'
                    Uri      = 'http://download.microsoft.com/download/3/D/9/3D95BF50-AED7-44A6-863B-BC7DC7C722CE/SQLServer2012-KB4091266-x64.exe'
                    Checksum = '54AF3D25BA0254440340E86320441A94'
                }
                @{
                    Id       = 'SSMS179'
                    Filename = 'SSMS-Setup-ENU.exe'
                    Uri      = 'https://download.microsoft.com/download/B/8/3/B839AD7D-DDC7-4212-9643-28E148251DC1/SSMS-Setup-ENU.exe'
                    Checksum = '9555158FEC4B01695B465B2F14C7A78D'
                }
                @{
                    Id       = 'NetFx472'
                    Filename = 'NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
                    Uri      = 'https://download.microsoft.com/download/6/E/4/6E48E8AB-DC00-419E-9704-06DD46E5F81D/NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
                    Checksum = '87450CFA175585B23A76BBD7052EE66B'
                }
            )
        }
    }
}
