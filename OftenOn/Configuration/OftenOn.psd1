@{
    AllNodes = @(
        @{
            Thumbprint = '5940D7352AB397BFB2F37856AA062BB471B43E5E'
            Lability_StartupMemory = 1073741824
            Lability_Resource = @(
                'NlaSvcFix',
                'TriggerDsc'
            )
            FullyQualifiedDomainName = 'oftenon.com'
            PSDscAllowDomainUser = $true
            Lability_ProcessorCount = 2
            Lability_GuestIntegrationServices = $true
            NodeName = '*'
            Role = @{}
            Lability_BootOrder = 3
            DomainName = 'OFTENON'
            CertificateFile = '$env:ALLUSERSPROFILE\Lability\Certificates\LabClient.cer'
            Lability_HardDiskDrive = @(
                @{
                    Generation = 'VHDX'
                    MaximumSizeBytes = 136365211648
                }
            )
        },
        @{
            Lability_BootDelay = 60
            Lability_Media = 'Windows Server 2016 Standard 64bit English Evaluation'
            NodeName = 'CHDC01'
            Lability_BootOrder = 1
            Role = @{
                Router = @{}
                DomainController = @{}
            }
            Lability_Resource = @(
                'NlaSvcFix',
                'TriggerDsc',
                'SQLServer2012',
                'SQLServer2012SP4',
                'SQLServer2012SP4GDR',
                'SQLServer2012SP4GDRHotfix',
                'SQLServer2017',
                'SQLServer2017CU19',
                'SSMS184',
                'NetFx472'
            )
            Network = @(
                @{
                    DnsServerAddress = '127.0.0.1'
                    NetAdapterName = 'CHICAGO'
                    SwitchName = 'CHICAGO'
                    IPAddress = '10.0.0.1/24'
                },
                @{
                    DnsServerAddress = '127.0.0.1'
                    NetAdapterName = 'SEATTLE'
                    SwitchName = 'SEATTLE'
                    IPAddress = '10.0.1.1/24'
                },
                @{
                    DnsServerAddress = '127.0.0.1'
                    NetAdapterName = 'DALLAS'
                    SwitchName = 'DALLAS'
                    IPAddress = '10.0.2.1/24'
                },
                @{
                    NetAdapterName = 'SEATTLE_HB'
                    SwitchName = 'SEATTLE_HB'
                    IPAddress = '10.0.11.1/24'
                },
                @{
                    NetAdapterName = 'DALLAS_HB'
                    SwitchName = 'DALLAS_HB'
                    IPAddress = '10.0.12.1/24'
                },
                @{
                    DnsServerAddress = '127.0.0.1'
                    NetAdapterName = 'WAN'
                    SwitchName = 'Default Switch'
                }
            )
        },
        @{
            Role = @{
                Workstation = @{}
                DomainMember = @{}
            }
            NodeName = 'CHWK01'
            Network = @(
                @{
                    DnsServerAddress = '10.0.0.1'
                    NetAdapterName = 'CHICAGO'
                    SwitchName = 'CHICAGO'
                    IPAddress = '10.0.0.3/24'
                    DefaultGatewayAddress = '10.0.0.1'
                }
            )
            Lability_Media = 'Windows Server 2016 Standard 64bit English Evaluation'
        },
        @{
            Lability_BootDelay = 60
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
            NodeName = 'SEC1N1'
            Lability_BootOrder = 2
            Role = @{
                Cluster = @{
                    StaticAddress = '10.0.1.21/24'
                    IgnoreNetwork = '10.0.11.0/24'
                    Name = 'C1'
                }
                DomainMember = @{}
                AvailabilityGroup = @{
                    FailoverMode = 'Automatic'
                    ListenerName = 'AG1L'
                    AvailabilityMode = 'SynchronousCommit'
                    Name = 'AG1'
                    IPAddress = '10.0.1.31/255.255.255.0'
                }
                SqlServer = @{
                    InstanceName = 'MSSQLSERVER'
                    Features = 'SQLENGINE'
                    SourcePath = '\\CHDC01\Resources\SQLServer2012'
                }
            }
            Network = @(
                @{
                    DnsServerAddress = '10.0.0.1'
                    NetAdapterName = 'SEATTLE'
                    SwitchName = 'SEATTLE'
                    IPAddress = '10.0.1.11/24'
                    DefaultGatewayAddress = '10.0.1.1'
                },
                @{
                    NetAdapterName = 'SEATTLE_HB'
                    SwitchName = 'SEATTLE_HB'
                    IPAddress = '10.0.11.11/24'
                }
            )
        },
        @{
            Role = @{
                Cluster = @{
                    StaticAddress = '10.0.1.21/24'
                    IgnoreNetwork = '10.0.11.0/24'
                    Name = 'C1'
                }
                DomainMember = @{}
                AvailabilityGroup = @{
                    FailoverMode = 'Manual'
                    ListenerName = 'AG1L'
                    AvailabilityMode = 'AsynchronousCommit'
                    Name = 'AG1'
                    IPAddress = '10.0.1.31/255.255.255.0'
                }
                SqlServer = @{
                    InstanceName = 'MSSQLSERVER'
                    Features = 'SQLENGINE'
                    SourcePath = '\\CHDC01\Resources\SQLServer2012'
                }
            }
            NodeName = 'SEC1N2'
            Network = @(
                @{
                    DnsServerAddress = '10.0.0.1'
                    NetAdapterName = 'SEATTLE'
                    SwitchName = 'SEATTLE'
                    IPAddress = '10.0.1.12/24'
                    DefaultGatewayAddress = '10.0.1.1'
                },
                @{
                    NetAdapterName = 'SEATTLE_HB'
                    SwitchName = 'SEATTLE_HB'
                    IPAddress = '10.0.11.12/24'
                }
            )
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
        },
        @{
            Role = @{
                Cluster = @{
                    StaticAddress = '10.0.1.21/24'
                    IgnoreNetwork = '10.0.11.0/24'
                    Name = 'C1'
                }
                DomainMember = @{}
                AvailabilityGroup = @{
                    FailoverMode = 'Manual'
                    ListenerName = 'AG1L'
                    AvailabilityMode = 'AsynchronousCommit'
                    Name = 'AG1'
                    IPAddress = '10.0.1.31/255.255.255.0'
                }
                SqlServer = @{
                    InstanceName = 'MSSQLSERVER'
                    Features = 'SQLENGINE'
                    SourcePath = '\\CHDC01\Resources\SQLServer2012'
                }
            }
            NodeName = 'SEC1N3'
            Network = @(
                @{
                    DnsServerAddress = '10.0.0.1'
                    NetAdapterName = 'SEATTLE'
                    SwitchName = 'SEATTLE'
                    IPAddress = '10.0.1.13/24'
                    DefaultGatewayAddress = '10.0.1.1'
                },
                @{
                    NetAdapterName = 'SEATTLE_HB'
                    SwitchName = 'SEATTLE_HB'
                    IPAddress = '10.0.11.13/24'
                }
            )
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
        },
        @{
            Role = @{
                Cluster = @{
                    StaticAddress = '10.0.2.21/24'
                    IgnoreNetwork = '10.0.12.0/24'
                    Name = 'C1'
                }
                DomainMember = @{}
                AvailabilityGroup = @{
                    FailoverMode = 'Automatic'
                    ListenerName = 'AG1L'
                    AvailabilityMode = 'SynchronousCommit'
                    Name = 'AG1'
                    IPAddress = '10.0.2.31/255.255.255.0'
                }
                SqlServer = @{
                    InstanceName = 'MSSQLSERVER'
                    Features = 'SQLENGINE'
                    SourcePath = '\\CHDC01\Resources\SQLServer2012'
                }
            }
            NodeName = 'DAC1N1'
            Network = @(
                @{
                    DnsServerAddress = '10.0.0.1'
                    NetAdapterName = 'DALLAS'
                    SwitchName = 'DALLAS'
                    IPAddress = '10.0.2.11/24'
                    DefaultGatewayAddress = '10.0.2.1'
                },
                @{
                    NetAdapterName = 'DALLAS_HB'
                    SwitchName = 'DALLAS_HB'
                    IPAddress = '10.0.12.11/24'
                }
            )
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
        },
        @{
            Role = @{
                Cluster = @{
                    StaticAddress = '10.0.2.21/24'
                    IgnoreNetwork = '10.0.12.0/24'
                    Name = 'C1'
                }
                DomainMember = @{}
                AvailabilityGroup = @{
                    FailoverMode = 'Manual'
                    ListenerName = 'AG1L'
                    AvailabilityMode = 'AsynchronousCommit'
                    Name = 'AG1'
                    IPAddress = '10.0.2.31/255.255.255.0'
                }
                SqlServer = @{
                    InstanceName = 'MSSQLSERVER'
                    Features = 'SQLENGINE'
                    SourcePath = '\\CHDC01\Resources\SQLServer2012'
                }
            }
            NodeName = 'DAC1N2'
            Network = @(
                @{
                    DnsServerAddress = '10.0.0.1'
                    NetAdapterName = 'DALLAS'
                    SwitchName = 'DALLAS'
                    IPAddress = '10.0.2.12/24'
                    DefaultGatewayAddress = '10.0.2.1'
                },
                @{
                    NetAdapterName = 'DALLAS_HB'
                    SwitchName = 'DALLAS_HB'
                    IPAddress = '10.0.12.12/24'
                }
            )
            Lability_Media = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
        }
    )
    NonNodeData = @{
        Lability = @{
            Module = @(
                @{
                    RequiredVersion = '4.9.0'
                    Name = 'Pester'
                },
                @{
                    RequiredVersion = '1.7.4.4'
                    Name = 'PoshRSJob'
                },
                @{
                    RequiredVersion = '21.1.18179'
                    Name = 'SqlServer'
                },
                @{
                    RequiredVersion = '1.6.3'
                    Name = 'Cim'
                },
                @{
                    RequiredVersion = '2.2.2'
                    Name = 'DbData'
                },
                @{
                    RequiredVersion = '1.5.3'
                    Name = 'DbSmo'
                },
                @{
                    RequiredVersion = '1.5.1'
                    Name = 'Disposable'
                },
                @{
                    RequiredVersion = '1.5.1'
                    Name = 'Error'
                },
                @{
                    RequiredVersion = '4.1.5'
                    Name = 'Jojoba'
                },
                @{
                    RequiredVersion = '1.1.1'
                    Name = 'ParseSql'
                },
                @{
                    RequiredVersion = '1.5.1'
                    Name = 'Performance'
                }
            )
            DSCResource = @(
                @{
                    RequiredVersion = '8.0.0'
                    Name = 'ComputerManagementDsc'
                },
                @{
                    RequiredVersion = '7.4.0.0'
                    Name = 'NetworkingDsc'
                },
                @{
                    RequiredVersion = '3.0.0.0'
                    Name = 'xActiveDirectory'
                },
                @{
                    RequiredVersion = '1.16.0.0'
                    Name = 'xDnsServer'
                },
                @{
                    RequiredVersion = '2.2.0.0'
                    Name = 'xSmbShare'
                },
                @{
                    RequiredVersion = '1.5.0'
                    Name = 'xSystemSecurity'
                },
                @{
                    RequiredVersion = '2.8.0.0'
                    Name = 'xWindowsUpdate'
                },
                @{
                    RequiredVersion = '1.14.1'
                    Name = 'xFailOverCluster'
                },
                @{
                    RequiredVersion = '9.0.0'
                    Name = 'xPSDesiredStateConfiguration'
                },
                @{
                    RequiredVersion = '13.3.0'
                    Name = 'SqlServerDsc'
                }
            )
            Resource = @(
                @{
                    Expand = $true
                    Checksum = 'C44C1869A7657001250EF8FAD4F636D3'
                    Filename = 'SQLFULL_ENU.iso'
                    Uri = 'https://download.microsoft.com/download/4/C/7/4C7D40B9-BCF8-4F8A-9E76-06E9B92FE5AE/ENU/SQLFULL_ENU.iso'
                    Id = 'SQLServer2012'
                },
                @{
                    Checksum = '5EFF56819F854866CCBAE26F0D091B63'
                    Filename = 'SQLServer2012SP4-KB4018073-x64-ENU.exe'
                    Uri = 'https://download.microsoft.com/download/E/A/B/EABF1E75-54F0-42BB-B0EE-58E837B7A17F/SQLServer2012SP4-KB4018073-x64-ENU.exe'
                    Id = 'SQLServer2012SP4'
                },
                @{
                    Checksum = 'FBD078835E0BDF5815271F848FD8CF58'
                    Filename = 'SQLServer2012-KB4057116-x64.exe'
                    Uri = 'https://download.microsoft.com/download/F/6/1/F618E667-BA6E-4428-A36A-8B4F5190FCC8/SQLServer2012-KB4057116-x64.exe'
                    Id = 'SQLServer2012SP4GDR'
                },
                @{
                    Checksum = '54AF3D25BA0254440340E86320441A94'
                    Filename = 'SQLServer2012-KB4091266-x64.exe'
                    Uri = 'http://download.microsoft.com/download/3/D/9/3D95BF50-AED7-44A6-863B-BC7DC7C722CE/SQLServer2012-KB4091266-x64.exe'
                    Id = 'SQLServer2012SP4GDRHotfix'
                },
                @{
                    Checksum = '84A1EC2FF8CEB86B1AEDC613B144F4D9'
                    Filename = 'SQLServer2017-KB4535007-x64.exe'
                    Uri = 'https://download.microsoft.com/download/C/4/F/C4F908C9-98ED-4E5F-88D5-7D6A5004AEBD/SQLServer2017-KB4535007-x64.exe'
                    Id = 'SQLServer2017CU19'
                },
                @{
                    Checksum = '826BB5D7B783DCB9FB4194F326106850'
                    Filename = 'SSMS-Setup-ENU-17.9.1.exe'
                    Uri = 'https://download.microsoft.com/download/D/D/4/DD495084-ADA7-4827-ADD3-FC566EC05B90/SSMS-Setup-ENU.exe'
                    Id = 'SSMS1791'
                },
                @{
                    Checksum = '2FE1A67317AC4DE9669283817167D516'
                    Filename = 'SSMS-Setup-ENU-18.0.exe'
                    Uri = 'https://download.microsoft.com/download/5/4/E/54EC1AD8-042C-4CA3-85AB-BA307CF73710/SSMS-Setup-ENU.exe'
                    Id = 'SSMS180'
                },
                @{
                    Checksum = 'A092948409260FB68F72858337043E5C'
                    Filename = 'SSMS-Setup-ENU-18.1.exe'
                    Uri = 'https://download.microsoft.com/download/0/1/5/015ECB20-6206-4500-B73C-F3405553445A/SSMS-Setup-ENU.exe'
                    Id = 'SSMS181'
                },
                @{
                    Checksum = 'D6699E4B6E24A40F88C8D0A81792B458'
                    Filename = 'SSMS-Setup-ENU-18.2.exe'
                    Uri = 'https://download.microsoft.com/download/2/9/C/29CC9731-CE3B-4EC8-89D8-E6B8EE88EAF5/SSMS-Setup-ENU.exe'
                    Id = 'SSMS182'
                },
                @{
                    Checksum = '65D034096B63C6EC9051951BCF10088C'
                    Filename = 'SSMS-Setup-ENU-18.4.exe'
                    Uri = 'https://aka.ms/ssmsfullsetup'
                    Id = 'SSMS184'
                },
                @{
                    Checksum = '87450CFA175585B23A76BBD7052EE66B'
                    Filename = 'NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
                    Uri = 'https://download.microsoft.com/download/6/E/4/6E48E8AB-DC00-419E-9704-06DD46E5F81D/NDP472-KB4054530-x86-x64-AllOS-ENU.exe'
                    Id = 'NetFx472'
                },
                @{
                    Expand = $true
                    Checksum = '334FC5F8FDD269FB2D6D5DC1FD61D1C7'
                    Filename = 'SQLServer2017-x64-ENU.iso'
                    Uri = 'https://download.microsoft.com/download/E/F/2/EF23C21D-7860-4F05-88CE-39AA114B014B/SQLServer2017-x64-ENU.iso'
                    Id = 'SQLServer2017'
                },
                @{
                    Filename = '..\Scripts\NlaSvcFix.ps1'
                    Id = 'NlaSvcFix'
                    IsLocal = $true
                    DestinationPath = '\BootStrap'
                },
                @{
                    Filename = '..\Scripts\TriggerDsc.ps1'
                    Id = 'TriggerDsc'
                    IsLocal = $true
                    DestinationPath = '\BootStrap'
                }
            )
            Network = @(
                @{
                    Name = 'CHICAGO'
                    Type = 'Internal'
                },
                @{
                    Name = 'SEATTLE'
                    Type = 'Internal'
                },
                @{
                    Name = 'SEATTLE_HB'
                    Type = 'Private'
                },
                @{
                    Name = 'DALLAS'
                    Type = 'Internal'
                },
                @{
                    Name = 'DALLAS_HB'
                    Type = 'Private'
                }
            )
            Media = @(
                @{
                    MediaType = 'ISO'
                    Id = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
                    Filename = '9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    Architecture = 'x64'
                    Checksum = '8503997171F731D9BD1CB0B0EDC31F3D'
                    Uri = 'http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    CustomData = @{
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                        CustomBootStrap = @(
                            'NET USER Administrator /active:yes; ',
                            'Set-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force; #306',
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force;',
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                    }
                    Description = 'Windows Server 2012 Standard Evaluation (Server with a GUI)'
                    ImageName = 2
                    OperatingSystem = 'Windows'
                    Hotfixes = @(
                        @{
                            Id = 'W2K12-KB3191565-x64.msu'
                            Uri = 'https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/W2K12-KB3191565-x64.msu'
                        },
                        @{
                            Id = 'Windows8-RT-KB2803748-x64.msu'
                            Uri = 'https://download.microsoft.com/download/9/7/C/97CB21BF-FA24-46C7-BE44-88E7EE934841/Windows8-RT-KB2803748-x64.msu'
                        }
                    )
                },
                @{
                    MediaType = 'ISO'
                    Id = 'Windows Server 2016 Standard 64bit English Evaluation'
                    Filename = '14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'
                    Architecture = 'x64'
                    Checksum = '70721288BBCDFE3239D8F8C0FAE55F1F'
                    Uri = 'http://download.microsoft.com/download/1/4/9/149D5452-9B29-4274-B6B3-5361DBDA30BC/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO'
                    CustomData = @{
                        MinimumDismVersion = '10.0.0.0'
                        CustomBootStrap = @(
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
                    Description = 'Windows Server 2016 Standard 64bit English Evaluation'
                    ImageName = 2
                    OperatingSystem = 'Windows'
                    Hotfixes = @()
                }
            )
        }
    }
}
