@{
    AllNodes    = @(
        #region Generic settings
        @{
            NodeName                          = '*'

            # VM settings
            Lability_ProcessorCount           = 2
            Lability_StartupMemory            = 4GB
            Lability_GuestIntegrationServices = $true
            Lability_BootOrder                = 3
            <#
            # Additional hard disk drives, if you want them
            Lability_HardDiskDrive            = @(
                @{ Generation = 'VHDX'; MaximumSizeBytes = 100GB; }
            )
            #>

            # Encryption information (the script will translate the environment variable)
            CertificateFile                   = '$env:ALLUSERSPROFILE\Lability\Certificates\LabClient.cer'
            Thumbprint                        = '5940D7352AB397BFB2F37856AA062BB471B43E5E'
            PSDscAllowDomainUser              = $true

            FullyQualifiedDomainName          = 'oftenon.codykonior.com'
            DomainName                        = 'OFTENON'

            Lability_Resource                 = @(
                'NlaSvcFix'
                'TriggerDsc'
            )

            Role                              = @{ }
        }
        #endregion

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

        #region Domain Controller
        @{
            NodeName           = 'CHDC01'
            Lability_Media     = 'Windows Server 2016'
            Lability_BootOrder = 1
            Lability_BootDelay = 60

            Network            = @(
                @{ SwitchName = 'CHICAGO'; NetAdapterName = 'CHICAGO'; IPAddress = '10.0.0.1/24'; DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.1/24'; DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.1/24'; DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.1/24'; } # DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.1/24'; } # DnsServerAddress = '127.0.0.1'; }

                # DNS must point to itself so it can still resolve inner addresses
                @{ SwitchName = 'Default Switch'; NetAdapterName = 'WAN'; DnsServerAddress = '127.0.0.1'; }
            )

            Role               = @{
                DomainController = @{ }
                Router           = @{ }
            }

            Lability_Resource  = @(
                'NlaSvcFix'
                'TriggerDsc'

                'SQL Server 2012'
                'SQL Server 2014'
                'SQL Server 2016'
                'SQL Server 2019'
                'SQL Server 2022'
                'SQL Server Management Studio 16.5.3'
                'SQL Server Management Studio 17.9.1'
                'SQL Server Management Studio 18.12.1'
                'SQL Server Management Studio 19.3'
                'SQL Server Management Studio 20.2'
                'NET Framework 4.5.1'
                'NET Framework 4.5.2'
                'NET Framework 4.6'
                'NET Framework 4.6.1'
                'NET Framework 4.6.2'
                'NET Framework 4.7'
                'NET Framework 4.7.1'
                'NET Framework 4.7.2'
                'NET Framework 4.8'
                'NET Framework 4.8.1'
                'NET Framework 4.7.2'

                'SQL Server 2012 Service Pack 4 (KB4018073)'
                'Security Update for SQL Server 2012 Service Pack 4 CU (KB4583465)'
            )
        }
        #endregion

        #region Workstations
        @{
            NodeName       = 'CHDBA2016'
            Lability_Media = 'Windows Server 2016'
            Network        = @(
                @{ SwitchName = 'CHICAGO'; NetAdapterName = 'CHICAGO'; IPAddress = '10.0.0.13/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.0.1'; }
            )
            Role           = @{
                DomainMember = @{ }
                Workstation  = @{ }
            }
        }
        #endregion

        #region Windows Server 2012 Cluster, 5x SQL Server 2012
        @{
            NodeName           = 'SEC1N1'
            Lability_Media     = 'Windows Server 2012'
            Lability_BootOrder = 2
            Lability_BootDelay = 60
            Network            = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.11/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.11/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )
            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }
        @{
            NodeName       = 'SEC1N2'
            Lability_Media = 'Windows Server 2012'
            Network        = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.12/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.12/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )
            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }
        @{
            NodeName       = 'SEC1N3'
            Lability_Media = 'Windows Server 2012'
            Network        = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.13/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.13/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )
            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }
        @{
            NodeName       = 'DAC1N1'
            Lability_Media = 'Windows Server 2012'
            Network        = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.11/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.11/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )
            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.2.21/24'; IgnoreNetwork = '10.0.12.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.2.31/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }
        @{
            NodeName       = 'DAC1N2'
            Lability_Media = 'Windows Server 2012'
            Network        = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.12/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.12/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )
            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.2.21/24'; IgnoreNetwork = '10.0.12.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.2.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }

        #region Windows Server 2016 Cluster, 5x SQL Server 2017
        # Copy of the above region, with C1 -> C2, AG1 -> AG2, Windows Server 2012 -> Windows Server 2016, SQL Server 2012 -> SQL Server 2017
        # and add 1 to the third octet of each StaticAddress and IPAddress
        @{
            NodeName           = 'SEC2N1'
            Lability_Media     = 'Windows Server 2016'
            Lability_BootOrder = 2
            Lability_BootDelay = 60
            Network            = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.111/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.111/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )
            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.1.121/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.1.131/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }
        @{
            NodeName       = 'SEC2N2'
            Lability_Media = 'Windows Server 2016'
            Network        = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.112/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.112/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )
            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.1.121/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.1.131/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }
        @{
            NodeName       = 'SEC2N3'
            Lability_Media = 'Windows Server 2016'
            Network        = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.113/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.113/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )
            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.1.121/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.1.131/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }
        @{
            NodeName       = 'DAC2N1'
            Lability_Media = 'Windows Server 2016'
            Network        = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.111/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.111/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )
            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.2.121/24'; IgnoreNetwork = '10.0.12.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.2.131/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }
        @{
            NodeName       = 'DAC2N2'
            Lability_Media = 'Windows Server 2016'
            Network        = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.112/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.112/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )
            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.2.121/24'; IgnoreNetwork = '10.0.12.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQL Server 2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.2.131/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }
        #endregion
    )

    NonNodeData = @{
        Lability = @{
            # These resources are copied to the VM. If any are missing (except PSDesiredStateConfiguration) the first boot
            # will hang because DSC doesn't complete. Stopping and starting the VM will allow you to login to see the logs.
            DSCResource = @(
                @{ Name = 'ComputerManagementDsc'; RequiredVersion = '9.1.0'; }
                @{ Name = 'NetworkingDsc'; RequiredVersion = '9.0.0'; }
                @{ Name = 'ActiveDirectoryDsc'; RequiredVersion = '6.5.0'; }
                @{ Name = 'DnsServerDsc'; RequiredVersion = '3.0.0'; }
                @{ Name = 'FileSystemDsc'; RequiredVersion = '1.1.1'; }
                @{ Name = 'xWindowsUpdate'; RequiredVersion = '2.8.0.0'; }
                @{ Name = 'FailoverClusterDsc'; RequiredVersion = '2.1.0'; }
                @{ Name = 'xPSDesiredStateConfiguration'; RequiredVersion = '9.1.0'; }

                # This changes depending on whether I have pending fixes or not
                @{ Name = 'SqlServerDsc'; RequiredVersion = '16.6.0'; }
                # @{ Name = 'SqlServerDsc'; Path = "C:\Program Files\WindowsPowerShell\Modules\SqlServerDsc\16.6.0"; Provider = "FileSystem"; }
                # @{ Name = 'SqlServerDsc'; RequiredVersion = '16.0.0'; Provider = 'GitHub'; Owner = 'PowerShell'; Branch = 'dev'; }
            )

            # These non-DSC modules are copied over to the VMs for general purpose use.
            Module      = @(
                @{ Name = 'Pester'; RequiredVersion = '5.4.0'; }
                @{ Name = 'PoshRSJob'; RequiredVersion = '1.7.4.4'; }

                # This module is critical; to use v22 and above you MUST have NET Framework 4.7.2
                # installed on the server
                @{ Name = 'SqlServer'; RequiredVersion = '21.1.18256'; }
                # @{ Name = 'SqlServer'; RequiredVersion = '22.3.0'; }

                @{ Name = 'Cim'; RequiredVersion = '1.6.3'; }
                @{ Name = 'DbData'; RequiredVersion = '2.2.2'; }
                @{ Name = 'DbSmo'; RequiredVersion = '1.5.3'; }
                @{ Name = 'Disposable'; RequiredVersion = '1.5.1'; }
                @{ Name = 'Error'; RequiredVersion = '1.5.1'; }
                @{ Name = 'Jojoba'; RequiredVersion = '4.1.6'; }
                @{ Name = 'ParseSql'; RequiredVersion = '1.1.1'; }
                @{ Name = 'Performance'; RequiredVersion = '1.5.1'; }
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
                #region Windows Server Media
                @{
                    Id               = 'Windows Server 2012'
                    DownloadToFolder = $true
                    Filename         = '9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    Architecture     = 'x64'
                    Uri              = 'http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    Checksum         = ''
                    Description      = 'Windows Server 2012'
                    MediaType        = 'ISO'
                    ImageName        = 2 # This shows differently as 'Windows Server 2012' or on LTSB as 'Windows Server 2012 SERVERSTANDARD'
                    OperatingSystem  = 'Windows'
                    Hotfixes         = @(
                        @{
                            # WMF 5.1 for Windows Server 2012
                            Id  = 'W2K12-KB3191565-x64.msu'
                            # Filename and Checksum are ignored
                            # Filename = 'W2K12-KB3191565-x64.msu'
                            # Checksum = 'E978C87841BAED49FB68206DF5E1DF9C'
                            Uri = 'https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/W2K12-KB3191565-x64.msu'
                        }
                    )
                    CustomData       = @{
                        CustomBootStrap        = @(
                            'NET USER Administrator /active:yes'
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force'
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force'
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f'
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                    }
                }
                @{
                    Id               = 'Windows Server 2012 R2'
                    DownloadToFolder = $true
                    Filename         = '9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO'
                    Architecture     = 'x64'
                    Uri              = 'https://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO'
                    Checksum         = ''
                    Description      = 'Windows Server 2012 R2'
                    MediaType        = 'ISO'
                    ImageName        = 2 # This shows differently as 'Windows Server 2012' or on LTSB as 'Windows Server 2012 SERVERSTANDARD'
                    OperatingSystem  = 'Windows'
                    Hotfixes         = @(
                        @{
                            # WMF 5.1 for Windows Server 2012 R2
                            Id  = 'Win8.1AndW2K12R2-KB3191564-x64.msu'
                            # Filename and Checksum are ignored
                            # Filename = 'W2K12-KB3191565-x64.msu'
                            # Checksum = 'E978C87841BAED49FB68206DF5E1DF9C'
                            Uri = 'https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu'
                        }
                    )
                    CustomData       = @{
                        CustomBootStrap        = @(
                            'NET USER Administrator /active:yes'
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force'
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force'
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f'
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                    }
                }
                @{
                    Id               = 'Windows Server 2016'
                    DownloadToFolder = $true
                    Filename         = 'Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO'
                    Architecture     = 'x64'
                    Uri              = 'https://software-static.download.prss.microsoft.com/pr/download/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO'
                    Checksum         = ''
                    Description      = 'Windows Server 2016'
                    MediaType        = 'ISO'
                    ImageName        = 2
                    OperatingSystem  = 'Windows'
                    Hotfixes         = @()
                    CustomData       = @{
                        CustomBootStrap        = @(
                            'NET USER Administrator /active:yes'
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force'
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force'
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                        MinimumDismVersion     = '10.0.0.0'
                    }
                }
                @{
                    Id               = 'Windows Server 2019'
                    DownloadToFolder = $true
                    Filename         = '17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso'
                    Architecture     = 'x64'
                    Uri              = 'https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso'
                    Checksum         = ''
                    Description      = 'Windows Server 2019'
                    MediaType        = 'ISO'
                    ImageName        = 2
                    OperatingSystem  = 'Windows'
                    Hotfixes         = @()
                    CustomData       = @{
                        CustomBootStrap        = @(
                            'NET USER Administrator /active:yes'
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force'
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force'
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f'
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                        MinimumDismVersion     = '10.0.0.0'
                    }
                }
                @{
                    Id               = 'Windows Server 2022'
                    DownloadToFolder = $true
                    Filename         = 'SERVER_EVAL_x64FRE_en-us.iso'
                    Architecture     = 'x64'
                    Uri              = 'https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso'
                    Checksum         = ''
                    Description      = 'Windows Server 2022'
                    MediaType        = 'ISO'
                    ImageName        = 2
                    OperatingSystem  = 'Windows'
                    Hotfixes         = @()
                    CustomData       = @{
                        CustomBootStrap        = @(
                            'NET USER Administrator /active:yes'
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force'
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force'
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f'
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                        MinimumDismVersion     = '10.0.0.0'
                    }
                }
                #endregion
            )

            Resource    = @(
                #region Resources for NET Framework
                @{
                    Id               = 'NET Framework 4.5.1'
                    DownloadToFolder = $true
                    Filename         = 'NDP451-KB2858728-x86-x64-AllOS-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/1/6/7/167F0D79-9317-48AE-AEDB-17120579F8E2/NDP451-KB2858728-x86-x64-AllOS-ENU.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.5.2'
                    DownloadToFolder = $true
                    Filename         = 'NDP452-KB2901907-x86-x64-AllOS-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.6'
                    DownloadToFolder = $true
                    Filename         = 'NDP46-KB3045557-x86-x64-AllOS-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/6/F/9/6F9673B1-87D1-46C4-BF04-95F24C3EB9DA/enu_netfx/NDP46-KB3045557-x86-x64-AllOS-ENU_exe/NDP46-KB3045557-x86-x64-AllOS-ENU.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.6.1'
                    DownloadToFolder = $true
                    Filename         = 'NDP461-KB3102436-x86-x64-AllOS-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/E/4/1/E4173890-A24A-4936-9FC9-AF930FE3FA40/NDP461-KB3102436-x86-x64-AllOS-ENU.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.6.2'
                    DownloadToFolder = $true
                    Filename         = 'ndp462-kb3151800-x86-x64-allos-enu.exe'
                    Uri              = 'https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/80b431456d8866ebe053eb8b81a168b3/ndp462-kb3151800-x86-x64-allos-enu.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.7'
                    DownloadToFolder = $true
                    Filename         = 'ndp47-kb3186497-x86-x64-allos-enu.exe'
                    Uri              = 'https://download.visualstudio.microsoft.com/download/pr/2dfcc711-bb60-421a-a17b-76c63f8d1907/e5c0231bd5d51fffe65f8ed7516de46a/ndp47-kb3186497-x86-x64-allos-enu.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.7.1'
                    DownloadToFolder = $true
                    Filename         = 'ndp471-kb4033342-x86-x64-allos-enu.exe'
                    Uri              = 'https://download.visualstudio.microsoft.com/download/pr/4312fa21-59b0-4451-9482-a1376f7f3ba4/9947fce13c11105b48cba170494e787f/ndp471-kb4033342-x86-x64-allos-enu.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.7.2'
                    DownloadToFolder = $true
                    Filename         = 'ndp472-kb4054530-x86-x64-allos-enu.exe'
                    Uri              = 'https://download.visualstudio.microsoft.com/download/pr/1f5af042-d0e4-4002-9c59-9ba66bcf15f6/089f837de42708daacaae7c04b7494db/ndp472-kb4054530-x86-x64-allos-enu.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.8'
                    DownloadToFolder = $true
                    Filename         = 'ndp48-x86-x64-allos-enu.exe'
                    Uri              = 'https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'NET Framework 4.8.1'
                    DownloadToFolder = $true
                    Filename         = 'ndp481-x86-x64-allos-enu.exe'
                    Uri              = 'https://download.visualstudio.microsoft.com/download/pr/6f083c7e-bd40-44d4-9e3f-ffba71ec8b09/3951fd5af6098f2c7e8ff5c331a0679c/ndp481-x86-x64-allos-enu.exe'
                    Checksum         = ''
                }
                #endregion

                #region Resources for Management Studio
                @{
                    Id               = 'SQL Server Management Studio 16.5.3'
                    DownloadToFolder = $true
                    Filename         = 'SSMS-Setup-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/9/3/3/933EA6DD-58C5-4B78-8BEC-2DF389C72BE0/SSMS-Setup-ENU.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'SQL Server Management Studio 17.9.1'
                    DownloadToFolder = $true
                    Filename         = 'SSMS-Setup-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/D/D/4/DD495084-ADA7-4827-ADD3-FC566EC05B90/SSMS-Setup-ENU.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'SQL Server Management Studio 18.12.1'
                    DownloadToFolder = $true
                    Filename         = 'SSMS-Setup-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/8/a/8/8a8073d2-2e00-472b-9a18-88361d105915/SSMS-Setup-ENU.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'SQL Server Management Studio 19.3'
                    DownloadToFolder = $true
                    Filename         = 'SSMS-Setup-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/7/7/3/7738e337-ed99-40ea-b8ae-f639162c83c3/SSMS-Setup-ENU.exe'
                    Checksum         = ''
                }
                @{
                    Id               = 'SQL Server Management Studio 20.2'
                    DownloadToFolder = $true
                    Filename         = 'SSMS-Setup-ENU.exe'
                    Uri              = 'https://download.microsoft.com/download/9/b/e/9bee9f00-2ee2-429a-9462-c9bc1ce14c28/SSMS-Setup-ENU.exe'
                    Checksum         = ''
                }

                #region Resources for SQL Server
                @{
                    Id               = 'SQL Server 2012'
                    DownloadToFolder = $true
                    Filename         = 'en_sql_server_2012_developer_edition_x86_x64_dvd_813280.iso'
                    Uri              = 'https://myvs.download.prss.microsoft.com/dbazure/en_sql_server_2012_developer_edition_x86_x64_dvd_813280.iso?t=f30c5053-bee2-4622-b1f8-e78ddd6b5ae0&P1=1721391408&P2=601&P3=2&P4=W45rX79oT9ft3pHGmMo4EvdHKGCoWH%2bswE0IxEt05Eewk0K3uGzxWtGOO67dobdlJHV4XUenlcBdLAXyKSu%2bi5PjM6yGvoIgqXRJAwRyoY5dl42wRT4Zx3UcRY1oJXtStZM5te6njBY%2bIecZ3qeAVz97MhGtk%2fY47jOj540Aq17ef%2f7q2pv8AC5VLGKPi8U3RzjajwQJvl9oTwaD%2f7svPgHTO4VS5MoX5LQxpdmdgutabZHwcnMwvpI5vEcsYlXufzNnNSHIzfSeVX85uncy3VR7YzPQjs9Iy8FpKhcIuu1yPumgcTaPMnC42RzSzt6HCjnpiCi99a46u%2ffawrQbrA%3d%3d&su=1'
                    Checksum         = ''
                    Expand           = $true
                }
                @{
                    Id               = 'SQL Server 2014'
                    DownloadToFolder = $true
                    Filename         = 'en_sql_server_2014_developer_edition_x64_dvd_3940406.iso'
                    Uri              = 'https://myvs.download.prss.microsoft.com/dbazure/en_sql_server_2014_developer_edition_x64_dvd_3940406.iso?t=93490e4a-f779-4a3c-a159-8b5cdb4e48c7&P1=1721391477&P2=601&P3=2&P4=lyhUBl73YHoL43XApoe%2f3eORDYiJGNUEhVdc5SxInRPmxN42hQ74F6RPR0zhsxe8p2nMBWl%2fNCq8UC4YSVCYVOtPyb4SN6AYJKBY7nTkbEtP1PxRIaBP7e8sH%2bICwZDRY7ksAGgSiYvfH4a3P1gwfL48AciOf6nrYmP08DjfCOWQSh2YR18B%2b7GtnHVZ8e3nj375GP3KTI18ARTC6Kdq%2fb0WtQwQJkgIXPMm0Gwbm%2bo8v8u72MfgAX1OA3jd2hFLdp34Bm8UlDTlwq4uytgvf3rWakG0E0vCCbYuacxlIhdIiJTZdT6W8ik7cpdROY8hAHAHIc0XT3%2ffRNHlFUfB6Q%3d%3d&su=1'
                    Checksum         = ''
                    Expand           = $true
                }
                @{
                    Id               = 'SQL Server 2016'
                    DownloadToFolder = $true
                    Filename         = 'en_sql_server_2016_developer_x64_dvd_8777069.iso'
                    Uri              = 'https://myvs.download.prss.microsoft.com/dbazure/en_sql_server_2016_developer_x64_dvd_8777069.iso?t=c2bf9840-cb90-4c48-ae85-7db3850fccd0&P1=1721391502&P2=601&P3=2&P4=0qHwpQo8ozfFgefl1rEERdcJFbBMDe5jma4Do%2btBlxL%2bakiU2fX2%2fB6IwfFjfPUUvYIhqqTI18T6TlxaGv%2bsxQaTYzAE3FkO0W1lr5gzx3z71nMVvuNdV3kV6U5nABfcS2LrjTIW7EW7EC4ZlYzUHZT8vM1yCI4oUmbew3iTR6WOtJq3Bl9IbNC3vNFI1KHpApHziJa5GyGouASSoWb8JNKczj5Oq8fywaPuDSF3CB2y1hiBwHIpkFd5dn2hPw2R62USmryIWX8MdnczSNELQR0Ug9J2nKHAR7qso2lzYPPc8JFwfnke1WrgHaQqVuvaHEqBVgm7XqOUwKRQffgJgw%3d%3d&su=1'
                    Checksum         = ''
                    Expand           = $true
                }
                @{
                    Id               = 'SQL Server 2019'
                    DownloadToFolder = $true
                    Filename         = 'en_sql_server_2019_developer_x64_dvd_baea4195.iso'
                    Uri              = 'https://myvs.download.prss.microsoft.com/dbazure/en_sql_server_2019_developer_x64_dvd_baea4195.iso?t=1fe42426-3f14-45de-8f1f-ec0069114d2a&P1=1721391521&P2=601&P3=2&P4=WsYuOkH5vrKsvQx9PFW3YR2IjMCHod2mSyUlpfJjLQqfSHZ0MZssQTuRsWJCKUOFwnhxdIIjI6O7nhC5a1o%2b5XcTFw6WtcVYJf%2fyuqPzHp138URQw4Qhh0O5KZGXeRuBamGg6ufxbJdIi3oM%2fILWXA6ngWnkBd%2bXGLHSKcJuV4C4iezt%2f2rxFBj5tOltw2488UUeoe59M2Av4gh6fuAICNuUaMyFleqaggD78joVDCvGHAeq%2fVyR4Nnpk9cykm%2fVLivEXYP21%2fJCzo9nSc8Fyomc5dOLdM6owIab%2fbT%2bDvzybPS2yMCzn4Mp6HaC7FgG3F1%2boi15DE4ABQ9OLFlq%2bg%3d%3d&su=1'
                    Checksum         = ''
                    Expand           = $true
                }
                @{
                    Id               = 'SQL Server 2022'
                    DownloadToFolder = $true
                    Filename         = 'enu_sql_server_2022_developer_edition_x64_dvd_7cacf733.iso'
                    Uri              = 'https://myvs.download.prss.microsoft.com/dbazure/enu_sql_server_2022_developer_edition_x64_dvd_7cacf733.iso?t=9633b1f6-805a-4d5b-949b-ca1fd1fbaa82&P1=1721391538&P2=601&P3=2&P4=RzBCD4hizfUfrSCMvdUlCE5lDbdTvyrad4EOhCNlOCxpvEcXyEzZ8iqjDW3qaoEIOxGRM04M03qvRlv4cMhDnGaDQMCA9jD%2bkLkoXg0p2RmYFuYc%2fJVzxc5wpbewmyS0plUCxSRqSLj7I7bVFEIm9X6GyBtVgt9J7RRlWtYCE7vVZWfCSfm%2bIthHNHHGPBwLLr4IER%2bWgEoJ9e04MTfmP44R6qMVHTtaudzJBsUZcf8mKEGEazr5Nlhv9A%2f4AcQofP5r9YQXijO9lm3tGfJa9GzTy6QHUl37ZdotJ%2b%2bWwVjosvltgv%2f79cH%2bdA5ukwyG%2bzV7TvKhHnlVBsZ5PImt6g%3d%3d&su=1'
                    Checksum         = ''
                    Expand           = $true
                }
                #endregion

                #region Resources for internal use
                @{
                    Id              = 'NlaSvcFix'
                    IsLocal         = $true
                    Filename        = '..\Scripts\NlaSvcFix.ps1'
                    DestinationPath = '\BootStrap'
                }
                @{
                    Id              = 'TriggerDsc'
                    IsLocal         = $true
                    Filename        = '..\Scripts\TriggerDsc.ps1'
                    DestinationPath = '\BootStrap'
                }
                #endregion

                #region Other
                @{
                    Id               = 'Microsoft SQL Server 2012 Service Pack 1 (KB2674319)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012sp1-kb2674319-x64-enu_58c45506605b17150983123ca1a3e020928d84b9.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 Service Pack 2 (KB2958429)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012sp2-kb2958429-x64-enu_de8354a626886cf7348a95c3fd89012b711d6818.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 Service Pack 3 (KB3072779)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012sp3-kb3072779-x64-enu_dbf01b6dc6d60c2b045c92d91862e6087ad72a0a.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP2 Cumulative Update (CU) 10 KB3120313'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3120313-x64_392559ae47509bc3e55b9225b8d3b20b76af4725.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP2 Cumulative Update (CU) 11 KB3137745'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3137745-x64_3c319bc86826e624bfa4a128365d513c8bc0c81a.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP2 Cumulative Update (CU) 12 KB3152637'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3152637-x64_4b2a1a46815a62643e878cdbd8a78d7bbfdeaee8.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP2 Cumulative Update (CU) 13 KB3165266'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3165266-x64_be7d74745aebb19f191f1d8339b34c2a5e539b52.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP2 Cumulative Update (CU) 14 KB3180914'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3180914-x64_6a9bd6357acb335c5cbbbf11f34f87e35ca0196f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP3 Cumulative Update (CU) 1 KB3123299'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3123299-x64_6e6c4aa8bfca242c287066a9a9434e3a00943e94.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP3 Cumulative Update (CU) 2 KB3137746'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3137746-x64_e73195fa75b1b346700a95a29dd0fc7f6099aee1.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP3 Cumulative Update (CU) 3 KB3152635'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3152635-x64_95aea9842908d9cd83d1d6f9e0427e80669d528f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP3 Cumulative Update (CU) 4 KB3165264'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3165264-x64_2fda1cc614fcdb6715cae391795cd334247cc33f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Microsoft SQL Server 2012 SP3 Cumulative Update (CU) 5 KB3180915'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3180915-x64_7b95a36b8a2e31fafc268b75e5b971d68c79fc6c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 RTM (KB2716441)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb2716441-x64_a38e6163c727d5ee86ef6a103419ba34562f8cdb.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 RTM (KB2716442)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb2716442-x64_8b737896dee0508fda8efdb7f51c5629b7eb9b91.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 1 (KB2977325)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb2977325-x64_7126da164789ef1be327e3d3431e6ddab36898de.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 1 (KB2977326)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb2977326-x64_8de271ed94166ae0915236a0c8f8a287afe04ef4.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 1 (KB3045317)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3045317-x64_dc222c42cb297af745206fec69284de68564034f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 1 (KB3045318)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3045318-x64_3907d610c8617006511645ef893519fa561bf20d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 2 (KB3045319)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3045319-x64_5e52e0cab1c79474394fdc05412bf83b99fb0465.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 2 (KB3045321)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3045321-x64_458032f7bda3f45c0641c5417628034080297f4f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 2 CU (KB3194725)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3194725-x64_24d88ee43de5a81a98b1607b56350b81b902eeaa.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 2 GDR (KB3194719)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3194719-x64_7f827a7365e92225f410f607cd2a4d480a4f76f7.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 3 CU (KB3194724)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3194724-x64_edd46ea0de5c7539c5facd735b50334719b3268f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 3 CU (KB4019090)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4025925-x64_b56e18bcc3a90707a558f04e3c7200eee0277239.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 3 CU (KB4057121)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4057121-x64_b8ab5671b7c5c1a310e417f237f93022085888ab.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 3 GDR (KB3194721)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3194721-x64_73bf6fe884433386829e53ce887d2e4ccf40123c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 3 GDR (KB4019092)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4019092-x64_3cb6f8b3c74c3af75d55c8f0d015b52536768418.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 3 GDR (KB4057115)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4057115-x64_1f09537f60bd4943cb90171102c33b872534afdb.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 4 CU (KB4057116)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4057116-x64_c0c2e0e6519363a5bb3d3ca78d55ef664a8c8995.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 4 CU (KB4532098)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4532098-x64_e20fa98775d4983a042e987caa6d59eba46ec760.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2012 Service Pack 4 CU (KB4583465)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4583465-x64_c6e5ea14425fed26b885ab6b70aba8622817fd8c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 1 Setup Update (KB2674319)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012sp1-sqlsupport-kb2674319-x64-enu_5c553cb601b119e71ac992aa49b6074de728f969.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 2 Cumulative Update (CU) 15 KB3205416'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3194725-x64_24d88ee43de5a81a98b1607b56350b81b902eeaa.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 2 Cumulative Update (CU) 16 KB3205054'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3205054-x64_dae2a73b534bd5459c299aee28c56507539f81f0.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 3 Cumulative Update (CU) 10 KB4025925'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4025925-x64_b56e18bcc3a90707a558f04e3c7200eee0277239.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 3 Cumulative Update (CU) 6 KB3194992'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3194724-x64_edd46ea0de5c7539c5facd735b50334719b3268f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 3 Cumulative Update (CU) 7 KB3205051'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb3205051-x64_4346749c4390b45b6ed234fc9523d3e59146ce6b.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 3 Cumulative Update (CU) 8 KB4013104'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4013104-x64_04425dc2b0d3cd5b790c84e4e30933e7f4e694b8.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 3 Cumulative Update (CU) 9 KB4016762'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb4016762-x64_dfa394f8d870154ab4afb8ce8bc3326560fcc135.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2012 Service Pack 4 (KB4018073)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012sp4-kb4018073-x64-enu_95127ee2e8dfef180752e531a83cd948c24a3a87.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Update for SQL Server 2012 Service Pack 1 (KB2833645)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb2833645-x64_794d935a6039b3e91ff426085804b624556c017c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Update for SQL Server 2012 Service Pack 1 (SmartSetup) (KB2793634) Part 1/3'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb2793634-x64_d80ce2bcb592d63cb9c64a92acba00f51f1f5359.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Update for SQL Server 2012 Service Pack 1 (SmartSetup) (KB2793634) Part 2/3'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-setupdata-kb2793634-x64_23fda2fc215c90dbd682db078f66ea0407401fea.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Update for SQL Server 2012 Service Pack 1 (SmartSetup) (KB2793634) Part 3/3'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-sqlsupport-kb2793634-x64_f563d91d1e5381f19476956c1da90923ef6fef41.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Update Rollup for SQL Server 2012 Service Pack 1 (KB2790947)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb2790947-x64_82120de2ca5055521f6655a1d5df2645940574ae.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Update Rollup for SQL Server 2012 Service Pack 1 (KB2793634)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2012-kb2793634-x64_d80ce2bcb592d63cb9c64a92acba00f51f1f5359.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 (KB4293803)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4293803-x64_1f53cdd60a7a459a19ee9ae37812be3898d50f85.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 CU (KB4293805)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4293805-x64_9db3528a3626a00bc125eff7d774e0f270dcd8b9.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM CU (KB4058562)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4052987-x64_a533b82e49cb9a5eea52cd2339db18aa4017587b.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM CU (KB4494352)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4494352-x64_5de157bedc6abe5b89a4dc8857f9a5b26c11ab69.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM CU (KB4505225)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4505225-x64_19c9cc25e7f118598c50dd016577b2dbfd6dfe93.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM CU (KB4583457)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4583457-x64_3a1f05dd6226db9cf98e428cfb483c4b05c6cebc.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM CU (KB5014553)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5014553-x64_273bf6ee251f21ff3bfd0c906296a7644d20ee3c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM CU (KB5021126)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5021126-x64_436fc3684f1add92ea7f4dfb18e9fe1bf95d3f80.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM CU (KB5029376)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5029376-x64_377595bd4ba0de82256f259bc770df907d935cb8.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM CU (KB5040940)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5040940-x64_828e3539f3689129496f934cd1e1443d534737df.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM GDR (KB4057122)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4057122-x64_48c5b2c6047a81871e9d72c62a73090411d68368.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM GDR (KB4494351)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4494351-x64_31ac1da09e364b65a16efb651c7aa467a78e5aee.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM GDR (KB4505224)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4505224-x64_573ca7cedf2e3df1c1fa4ce2fb1d2df6a8f24df9.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM GDR (KB4583456)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4583456-x64_bf7023c68ec114805813c6954e5eb430045f7ec5.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM GDR (KB5014354)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5014354-x64_9814f910225f12ff0fb57b6a530c2aab0709f277.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM GDR (KB5021127)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5021127-x64_6316f1011fe643006ff4d11fce96a9055fdd0d6a.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM GDR (KB5029375)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5029375-x64_fb8d0c8788868d85b7da8e0bf8411e2e37dc419c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2017 RTM GDR (KB5040942)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5040942-x64_e3ac9e71d789a293dc9e8a471b307cc18b49c0e7.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 1 KB4038634'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4038634-x64_a75ab79103d72ce094866404607c2e84ae777d43.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 10 KB4342123'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4342123-x64_7bfea85723fd0321d2555d4e5b8648115786757e.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 11 KB4462262'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4462262-x64_c974e2962d83a909c08bbe7a48c8c022e9076f58.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 12 KB4464082'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4464082-x64_f02243869552c7a8e21fe64ee5f2a78a7d52d979.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 13 KB4466404'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4466404-x64_5cf494b2be8d679ee407f03d77bcb574875f1f5b.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 14 KB4484710'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4484710-x64_59015db5853814c7f2ac24cd4722c0eae771829f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 15 KB4498951'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4498951-x64_b143d28a48204eb6ebab62394ce45df53d73f286.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 16 KB4508218'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4508218-x64_a7fefaa78e201c654262066d84eb5e1c1fbe3282.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 17 KB4515579'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4515579-x64_e6ab5e1c932edbff9ac99f1ba80998779745e6c6.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 18 KB4527377'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4527377-x64_cd2488e727d332802f77d5032e3e4b40da777f77.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 19 KB4535007'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4535007-x64_6c883a7a36a1029066e2be6ab9eeab0967804580.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 2 KB4052574'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4052574-x64_ee995c195fafbdff4b30f424cab6fd64e2a5262d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 20 KB4541283'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4541283-x64_b0f1a8f63ba7e9c155546a49f18fd95bc5e9aeaa.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 21 KB4557397'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4557397-x64_e91bfa33a34accf82a0c374c9e8b7d0ce3b7ce05.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 22 KB4577467'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4577467-x64_8848761ca6ccec75d62aa0ea221bfa3ca54ad105.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 23 KB5000685'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5000685-x64_c81205037e8cb594dc11faf538c66018383f8167.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 24 KB5001228'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5001228-x64_8a043ccb15fa259eca0224f59364658300c138aa.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 25 KB5003830'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5003830-x64_bcd8cf2bfa6d57fca1a6a916a3f54d11687aa97f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 26 KB5005226'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5005226-x64_e31b28ba9c4c0b63ddbb356f630e8ea631da97fe.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 27 KB5006944'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5006944-x64_1109176cec3724feb7e21b6e6804b0876229c7c9.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 28 KB5008084'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5008084-x64_875be48deb01a9d496ef16fa21f9352e8ac08ed8.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 29 KB5010786'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5010786-x64_e6afc1d37ed985fd786c1a71457274c508a6c99c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 3 KB4052987'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4052987-x64_a533b82e49cb9a5eea52cd2339db18aa4017587b.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 30 KB5013756'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5013756-x64_f4871b2167d371e508b73953ecbbcd42fc28f997.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 31 KB5016884'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb5016884-x64_ff02621395c103b1381924f4c4b137901a870261.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 4 KB4056498'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4056498-x64_d1f84e3cfbda5006301c8e569a66a982777a8a75.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 5 KB4092643'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4092643-x64_b462f2bc7e714b51e0ddd4511a3b3faf4b5d2c8e.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 6 KB4101464'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4101464-x64_e42478470a71c67424402031f50974ac7180c657.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 7 KB4229789'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4229789-x64_2851a9e2d5faadc45c7699f68a1382b8009608d8.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 8 KB4338363'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4338363-x64_f32613586a621cacba6d08ea7af0b10e1b5938f6.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2017 RTM Cumulative Update (CU) 9 KB4341265'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2017-kb4341265-x64_8a5011f798115001695945f8dbad395f4ee9d9a6.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM CU (KB4583459)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4583459-x64_e74e3587b8248c8b29200b9af1be0c4156881c5c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM CU (KB5014353)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5014353-x64_0f3515258eeab383c44a034a1d79d05b6ecc46fe.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM CU (KB5021124)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5021124-x64_93087e10289b94b3f4783f1d431358c4889ba1b3.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM CU (KB5029378)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5029378-x64_b08544ab2490e036206967f0cf4d54399496954d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM CU (KB5036335)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5036335-x64_29b8de42217a53c040e06447f467c3fa554f4f8d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM CU (KB5040948)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5040948-x64_08f7d8ccaa470bd969fe72d30aaa9b5de6ef7af3.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM GDR (KB4583458)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4583458-x64_f4fff8c8a897f72356466cca02513ef05e982674.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM GDR (KB5014356)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5014356-x64_ca66c218e3250d5b242579dbde2532a6bba3bba5.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM GDR (KB5021125)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5021125-x64_5a8bbdc761d8118e3fdd8c764197fcfbb294d083.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM GDR (KB5029377)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5029377-x64_0563a8953cc7afdbe9a2afd361cf05f1006fb187.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM GDR (KB5035434)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5035434-x64_660cf13e94a708251025c28634edf5b3c7e0ba2a.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2019 RTM GDR (KB5040986)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5040986-x64_9f8ed71646dbd0b00b49e043f9650a828835aaa6.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Servicing Update for SQL Server 2019 RTM GDR (KB4517790)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4517790-x64_6412a53eb385a693b48948a297816647d25fa5d5.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 1 KB4527376'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4527376-x64_01dcaca398f0c3380264078463fc1a6cc859ec7c.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 10 KB5001090'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5001090-x64_be37187855cc06466f38d4161ba6b9da24f2d2c6.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 11 KB5003249'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5003249-x64_a1b2d2845c5c66d7b9fced09309537d5fa7dc540.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 12 KB5004524'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5004524-x64_f145a82e48219e5bf80c7dcf57ea3c902c4d395f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 13 KB5005679'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5005679-x64_a6e4ec3e93be461565550973f8b8cdfdd5580967.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 14 KB5007182'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5007182-x64_f8b5c3398e9f347701066deb388c2fcd2d94eb31.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 15 KB5008996'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5008996-x64_f914e20d97650c2b2c09bd8f3d35d3f0feb1afd3.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 16 KB5011644'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5011644-x64_a38427fc9ed638fdbc0011be2c71a7b32f811b9e.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 17 KB5016394'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5016394-x64_b196811983841da3a07a6ef8b776c85d942a138f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 18 KB5017593'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5017593-x64_bd8ea599f044e3834b779bd99e8732a92ae869a8.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 19 KB5023049'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5023049-x64_a0df7db34758ce47d81286df13fd3d396c4abf51.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 2 KB4536075'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4536075-x64_b6c415cb0ce781e3e40e263d68dca6e3bc70a07d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 20 KB5024276'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5024276-x64_767c3007f656fc2d29091d6f7d9660e804761260.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 21 KB5025808'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5025808-x64_b4935d744a9f5abb67d43fac573ff059cb82f8c1.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 22 KB5027702'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5027702-x64_068e588c1dddb42f5cdb334c55c64d42f5eec95e.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 23 KB5030333'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5030333-x64_8a1e1b207018159cecbf5e8f92c1a4cae3112202.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 24 KB5031908'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5031908-x64_47d88362e4ce0ea7e1d0c33c5b0cba2291444cdc.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 25 KB5033688'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5033688-x64_a781728ac862e8cd97c508314f3ea4886b70bd84.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 26 KB5035123'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5035123-x64_f4c614713287412219caadffdc8ae0ff00698324.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 27 KB5037331'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5037331-x64_51a3839385638495b5609cfd75acd432d87f0181.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 3 KB4538853'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4538853-x64_e110a1af271b4e97840c713c1d8f44d159f2393e.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 4 KB4548597'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4548597-x64_654ea92437fde8aad04745c6c380e9e72289babf.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 5 KB4552255'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4552255-x64_c6a0778132b00ced30f06ee61875d58d7a7a70b2.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 6 KB4563110'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4563110-x64_505c6d0a8773909e87a0456978ffb43449a92309.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 8 KB4577194'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb4577194-x64_a09e2537b854ae384d965e998e53ce33cdc34f16.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2019 RTM Cumulative Update (CU) 9 KB5000642'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2019-kb5000642-x64_7146ecc67a3b7bc33f743ebb2c19cb6a18857f00.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM CU (KB5029503)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5029503-x64_602dce63ae8d6567feaf5db5911d7a81a724eb94.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM CU (KB5033592)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5033592-x64_6464a9a10376d893012d85f47b98faf56408ac6f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM CU (KB5036343)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5036343-x64_d5ef225ae7093d7762e30d576f94f4304fad217f.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM CU (KB5040939)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5040939-x64_5a365a839171fae290da262ed30613d1b763ac36.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM GDR (KB5021522)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5021522-x64_5743b6e10743934b9bd1b149b456ced5a25ef90d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM GDR (KB5029379)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5029379-x64_b37b67c38e6af28c63d95346d4a4320e729b98df.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM GDR (KB5032968)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5032968-x64_83be310d9724fd77a5fae90b210e593c88e52909.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM GDR (KB5035432)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5035432-x64_6228980787359ee2721c88523690840aa7b436ed.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'Security Update for SQL Server 2022 RTM GDR (KB5040936)'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5040936-x64_78b8d17fe19d856b66e8fcfd529365cf0ad1f6a9.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 1 KB5022375'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5022375-x64_ab34fe7633beef56c7bce1e212a6cf56c91f4e57.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 10 KB5031778'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5031778-x64_8e55c5f6d70155e9f7fc190383373917426668a2.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 11 KB5032679'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5032679-x64_a3adcca15177b4b6e9e8bea669196bcf1f8a21cc.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 12 KB5033663'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5033663-x64_a58455d6f9dea34bcf2508d9cc40388422fe8388.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 13 KB5036432'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5036432-x64_01edc2be6c988f5795c010566bb80c343b7bb982.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 2 KB5023127'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5023127-x64_8773dc0f893badbbd32531e2e8cc7889ffcb7f54.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 3 KB5024396'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5024396-x64_dcdb0dcb05dce5f9be87e6355f3077a488291b70.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 4 KB5026717'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5026717-x64_d6abee2fc65b806a2db2dc77590ddda77f6fa79d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 5 KB5026806'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5026806-x64_acb1d3f77f574f335ac4315aadd8feaf6dfc2d4d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 6 KB5027505'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5027505-x64_7e188a61f59eaf1011bc1625900202d7fbca6b0d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 7 KB5028743'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5028743-x64_18dab43fdb947ffa86ef4ec669666bef2f4221c2.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 8 KB5029666'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5029666-x64_30b8b3666963cf01cb09b35c26a34a04d89cde8d.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                @{
                    Id               = 'SQL Server 2022 RTM Cumulative Update (CU) 9 KB5030731'
                    DownloadToFolder = $true
                    Filename         = 'sqlserver2022-kb5030731-x64_80421eb6076cf67677f77df86402c2f602178328.exe'
                    Uri              = ''
                    Checksum         = ''
                    DestinationPath = '\Resources'
                }
                #endregion
                
            )
        }
    }
}
