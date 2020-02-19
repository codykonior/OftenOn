@{
    AllNodes    = @(
        @{
            NodeName                          = '*'

            # VM settings
            Lability_ProcessorCount           = 2
            Lability_StartupMemory            = 1GB
            # Additional hard disk drive
            Lability_HardDiskDrive            = @(
                @{ Generation = 'VHDX'; MaximumSizeBytes = 127GB; }
            )
            Lability_GuestIntegrationServices = $true
            Lability_BootOrder                = 3

            # Encryption information (the script will translate the environment variable)
            CertificateFile                   = '$env:ALLUSERSPROFILE\Lability\Certificates\LabClient.cer'
            Thumbprint                        = '5940D7352AB397BFB2F37856AA062BB471B43E5E'
            PSDscAllowDomainUser              = $true

            FullyQualifiedDomainName          = 'oftenon.com'
            DomainName                        = 'OFTENON'

            Lability_Resource                 = @(
                'NlaSvcFix',
                'TriggerDsc'
            )

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
            Lability_Media     = 'Windows Server 2016 Standard 64bit English Evaluation'
            Lability_BootOrder = 1
            Lability_BootDelay = 60

            Network            = @(
                @{ SwitchName = 'CHICAGO'; NetAdapterName = 'CHICAGO'; IPAddress = '10.0.0.1/24'; DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.1/24'; DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.1/24'; DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.1/24'; } # DnsServerAddress = '127.0.0.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.1/24'; } # DnsServerAddress = '127.0.0.1'; }

                # Dns must point to itself so it can still resolve inner addresses
                @{ SwitchName = 'Default Switch'; NetAdapterName = 'WAN'; DnsServerAddress = '127.0.0.1'; }
            )

            Role               = @{
                DomainController = @{ }
                Router           = @{ }
            }

            Lability_Resource  = @(
                'NlaSvcFix', 'TriggerDsc', 'SQLServer2012', 'SQLServer2012SP4', 'SQLServer2012SP4GDR', 'SQLServer2012SP4GDRHotfix', 'SQLServer2017', 'SQLServer2017CU19', 'SSMS184', 'NetFx472'
            )
        }

        @{
            NodeName       = 'CHWK01'
            Lability_Media = 'Windows Server 2016 Standard 64bit English Evaluation'

            Network        = @(
                @{ SwitchName = 'CHICAGO'; NetAdapterName = 'CHICAGO'; IPAddress = '10.0.0.3/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.0.1'; }
            )

            Role           = @{
                DomainMember = @{ }
                Workstation  = @{ }
            }
        }

        @{
            NodeName           = 'SEC1N1'
            Lability_Media     = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
            Lability_BootOrder = 2
            Lability_BootDelay = 60

            Network            = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.11/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.11/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }

        @{
            NodeName       = 'SEC1N2'
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'

            Network        = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.12/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.12/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }

        @{
            NodeName       = 'SEC1N3'
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'

            Network        = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.13/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.13/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.1.21/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.1.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }

        @{
            NodeName       = 'DAC1N1'
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'

            Network        = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.11/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.11/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )

            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.2.21/24'; IgnoreNetwork = '10.0.12.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.2.31/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }

        @{
            NodeName       = 'DAC1N2'
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'

            Network        = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.12/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.12/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )

            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C1'; StaticAddress = '10.0.2.21/24'; IgnoreNetwork = '10.0.12.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2012'; }
                AvailabilityGroup = @{ Name = 'AG1'; ListenerName = 'AG1L'; IPAddress = '10.0.2.31/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }

        #region Windows 2016 SQL 2017

        <#
            Add Lability_Media
            Change C1 to C2
            Change AG1 to AG2
            Removed ,SSMS,SSMS_ADV
            Change SQLServer2012 to SQLServer2017
            Add 1 to third subnet of StaticAddress and IPAddress
        #>

        @{
            NodeName           = 'SEC2N1'
            Lability_Media     = 'Windows Server 2016 Standard 64bit English Evaluation'
            Lability_BootOrder = 2
            Lability_BootDelay = 60

            Network            = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.111/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.111/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role               = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.1.121/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.1.131/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }

        @{
            NodeName       = 'SEC2N2'
            Lability_Media = 'Windows Server 2016 Standard 64bit English Evaluation'

            Network        = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.112/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.112/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.1.121/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.1.131/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }

        @{
            NodeName       = 'SEC2N3'
            Lability_Media = 'Windows Server 2016 Standard 64bit English Evaluation'

            Network        = @(
                @{ SwitchName = 'SEATTLE'; NetAdapterName = 'SEATTLE'; IPAddress = '10.0.1.113/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.1.1'; }
                @{ SwitchName = 'SEATTLE_HB'; NetAdapterName = 'SEATTLE_HB'; IPAddress = '10.0.11.113/24'; } # DnsServerAddress = '10.0.11.1'; DefaultGatewayAddress = '10.0.11.1'; }
            )

            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.1.121/24'; IgnoreNetwork = '10.0.11.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.1.131/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }

        @{
            NodeName       = 'DAC2N1'
            Lability_Media = 'Windows Server 2016 Standard 64bit English Evaluation'

            Network        = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.111/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.111/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )

            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.2.121/24'; IgnoreNetwork = '10.0.12.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.2.131/255.255.255.0'; AvailabilityMode = 'SynchronousCommit'; FailoverMode = 'Automatic'; }
            }
        }

        @{
            NodeName       = 'DAC2N2'
            Lability_Media = 'Windows Server 2016 Standard 64bit English Evaluation'

            Network        = @(
                @{ SwitchName = 'DALLAS'; NetAdapterName = 'DALLAS'; IPAddress = '10.0.2.112/24'; DnsServerAddress = '10.0.0.1'; DefaultGatewayAddress = '10.0.2.1'; }
                @{ SwitchName = 'DALLAS_HB'; NetAdapterName = 'DALLAS_HB'; IPAddress = '10.0.12.112/24'; } # DnsServerAddress = '10.0.12.1'; DefaultGatewayAddress = '10.0.12.1'; }
            )

            Role           = @{
                DomainMember      = @{ }
                Cluster           = @{ Name = 'C2'; StaticAddress = '10.0.2.121/24'; IgnoreNetwork = '10.0.12.0/24'; }
                SqlServer         = @{ InstanceName = 'MSSQLSERVER'; Features = 'SQLENGINE'; SourcePath = '\\CHDC01\Resources\SQLServer2017'; }
                AvailabilityGroup = @{ Name = 'AG2'; ListenerName = 'AG2L'; IPAddress = '10.0.2.131/255.255.255.0'; AvailabilityMode = 'AsynchronousCommit'; FailoverMode = 'Manual'; }
            }
        }
        #endregion Windows 2016 SQL 2017
    )

    NonNodeData = @{
        Lability = @{
            # These resources are copied to the VM. If any are missing (except PSDesiredStateConfiguration) the first boot
            # will hang because DSC doesn't complete. Stopping and starting the VM will allow you to login to see the logs.
            DSCResource = @(
                @{ Name = 'ComputerManagementDsc'; RequiredVersion = '8.0.0'; }
                @{ Name = 'NetworkingDsc'; RequiredVersion = '7.4.0.0'; }
                @{ Name = 'xActiveDirectory'; RequiredVersion = '3.0.0.0'; }
                @{ Name = 'xDnsServer'; RequiredVersion = '1.16.0.0'; }
                @{ Name = 'xSmbShare'; RequiredVersion = '2.2.0.0'; }
                @{ Name = 'xSystemSecurity'; RequiredVersion = '1.5.0'; }
                @{ Name = 'xWindowsUpdate'; RequiredVersion = '2.8.0.0'; }
                @{ Name = 'xFailOverCluster'; RequiredVersion = '1.14.1'; }
                @{ Name = 'xPSDesiredStateConfiguration'; RequiredVersion = '9.0.0'; }

                # This changes depending on whether I have pending fixes or not
                @{ Name = 'SqlServerDsc'; RequiredVersion = '13.3.0'; }
                # @{ Name = 'SqlServerDsc'; RequiredVersion = '13.3.0'; Provider = 'GitHub'; Owner = 'PowerShell'; Branch = 'dev'; }
            )

            # These non-DSC modules are copied over to the VMs for general purpose use.
            Module      = @(
                @{ Name = 'Pester'; RequiredVersion = '4.9.0'; }
                @{ Name = 'PoshRSJob'; RequiredVersion = '1.7.4.4'; }
                @{ Name = 'SqlServer'; RequiredVersion = '21.1.18179'; }

                @{ Name = 'Cim'; RequiredVersion = '1.6.3'; }
                @{ Name = 'DbData'; RequiredVersion = '2.2.2'; }
                @{ Name = 'DbSmo'; RequiredVersion = '1.5.3'; }
                @{ Name = 'Disposable'; RequiredVersion = '1.5.1'; }
                @{ Name = 'Error'; RequiredVersion = '1.5.1'; }
                @{ Name = 'Jojoba'; RequiredVersion = '4.1.5'; }
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
                @{
                    # https://www.microsoft.com/en-in/evalcenter/evaluate-windows-server-2012
                    Id              = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
                    Filename        = '9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    Architecture    = 'x64'
                    Uri             = 'http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    Checksum        = '8503997171F731D9BD1CB0B0EDC31F3D'
                    Description     = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
                    MediaType       = 'ISO'
                    ImageName       = 2 # This shows differently as 'Windows Server 2012 Standard Evaluation (Server with a GUI)' or on LTSB as 'Windows Server 2012 SERVERSTANDARD'
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
                            'NET USER Administrator /active:yes; ',
                            'Set-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force; #306',
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force;',
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                    }
                }
                @{
                    Id              = 'Windows Server 2016 Standard 64bit English Evaluation'
                    Filename        = '14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'
                    Architecture    = 'x64'
                    Uri             = 'http://download.microsoft.com/download/1/4/9/149D5452-9B29-4274-B6B3-5361DBDA30BC/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'
                    Checksum        = '70721288BBCDFE3239D8F8C0FAE55F1F'
                    Description     = 'Windows Server 2016 Standard 64bit English Evaluation'
                    MediaType       = 'ISO'
                    ImageName       = 2
                    OperatingSystem = 'Windows'
                    Hotfixes        = @()
                    CustomData      = @{
                        CustomBootStrap        = @(
                            'NET USER Administrator /active:yes; ',
                            'Set-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force; #306',
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force;',
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                        MinimumDismVersion     = '10.0.0.0'
                    }
                }
            )

            Resource    = @(
                @{
                    Id       = 'SQLServer2012'
                    Filename = 'SQLFULL_ENU.iso'
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
                    Id       = 'SQLServer2017CU19'
                    Filename = 'SQLServer2017-KB4535007-x64.exe'
                    Uri      = 'https://download.microsoft.com/download/C/4/F/C4F908C9-98ED-4E5F-88D5-7D6A5004AEBD/SQLServer2017-KB4535007-x64.exe'
                    Checksum = '84A1EC2FF8CEB86B1AEDC613B144F4D9'
                }
                @{
                    Id       = 'SSMS1791'
                    Filename = 'SSMS-Setup-ENU-17.9.1.exe'
                    Uri      = 'https://download.microsoft.com/download/D/D/4/DD495084-ADA7-4827-ADD3-FC566EC05B90/SSMS-Setup-ENU.exe'
                    Checksum = '826BB5D7B783DCB9FB4194F326106850'
                }
                @{
                    Id       = 'SSMS180'
                    Filename = 'SSMS-Setup-ENU-18.0.exe'
                    Uri      = 'https://download.microsoft.com/download/5/4/E/54EC1AD8-042C-4CA3-85AB-BA307CF73710/SSMS-Setup-ENU.exe'
                    Checksum = '2FE1A67317AC4DE9669283817167D516'
                }
                @{
                    Id       = 'SSMS181'
                    Filename = 'SSMS-Setup-ENU-18.1.exe'
                    Uri      = 'https://download.microsoft.com/download/0/1/5/015ECB20-6206-4500-B73C-F3405553445A/SSMS-Setup-ENU.exe'
                    Checksum = 'A092948409260FB68F72858337043E5C'
                }
                @{
                    Id       = 'SSMS182'
                    Filename = 'SSMS-Setup-ENU-18.2.exe'
                    Uri      = 'https://download.microsoft.com/download/2/9/C/29CC9731-CE3B-4EC8-89D8-E6B8EE88EAF5/SSMS-Setup-ENU.exe'
                    Checksum = 'D6699E4B6E24A40F88C8D0A81792B458'
                }
                @{
                    Id       = 'SSMS184'
                    Filename = 'SSMS-Setup-ENU-18.4.exe'
                    Uri      = 'https://aka.ms/ssmsfullsetup'
                    Checksum = 'D41D8CD98F00B204E9800998ECF8427E'
                }
                @{
                    Id       = 'NetFx472'
                    Filename = 'NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
                    Uri      = 'https://download.microsoft.com/download/6/E/4/6E48E8AB-DC00-419E-9704-06DD46E5F81D/NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
                    Checksum = '87450CFA175585B23A76BBD7052EE66B'
                }
                @{
                    Id       = 'SQLServer2017'
                    Filename = 'SQLServer2017-x64-ENU.iso'
                    Uri      = 'https://download.microsoft.com/download/E/F/2/EF23C21D-7860-4F05-88CE-39AA114B014B/SQLServer2017-x64-ENU.iso'
                    Checksum = '334FC5F8FDD269FB2D6D5DC1FD61D1C7'
                    Expand   = $true
                }
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
            )
        }
    }
}
