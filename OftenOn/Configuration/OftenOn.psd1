@{
    AllNodes = @(
        @{
            Lability_Resource = @(
                'NlaSvcFix',
                'TriggerDsc'
            )
            Thumbprint = '5940D7352AB397BFB2F37856AA062BB471B43E5E'
            NodeName = '*'
            Lability_ProcessorCount = 2
            Role = @{}
            PSDscAllowDomainUser = $true
            Lability_GuestIntegrationServices = $true
            DomainName = 'OFTENON'
            CertificateFile = '$env:ALLUSERSPROFILE\Lability\Certificates\LabClient.cer'
            Lability_StartupMemory = 4294967296
            Lability_BootOrder = 3
            FullyQualifiedDomainName = 'oftenon.codykonior.com'
        },
        @{
            Lability_BootDelay = 60
            Lability_Media = 'Windows Server 2016'
            NodeName = 'CHDC01'
            Lability_BootOrder = 1
            Role = @{
                Router = @{}
                DomainController = @{}
            }
            Lability_Resource = @(
                'NlaSvcFix',
                'TriggerDsc',
                'SQL Server 2012',
                'SQL Server 2014',
                'SQL Server 2016',
                'SQL Server 2019',
                'SQL Server 2022',
                'SQL Server Management Studio 16.5.3',
                'SQL Server Management Studio 17.9.1',
                'SQL Server Management Studio 18.12.1',
                'SQL Server Management Studio 19.3',
                'SQL Server Management Studio 20.2',
                'NET Framework 4.5.1',
                'NET Framework 4.5.2',
                'NET Framework 4.6',
                'NET Framework 4.6.1',
                'NET Framework 4.6.2',
                'NET Framework 4.7',
                'NET Framework 4.7.1',
                'NET Framework 4.7.2',
                'NET Framework 4.8',
                'NET Framework 4.8.1',
                'NET Framework 4.7.2'
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
                DomainMember = @{}
            }
            NodeName = 'CHDBA2012'
            Network = @(
                @{
                    DnsServerAddress = '10.0.0.1'
                    NetAdapterName = 'CHICAGO'
                    SwitchName = 'CHICAGO'
                    IPAddress = '10.0.0.11/24'
                    DefaultGatewayAddress = '10.0.0.1'
                }
            )
            Lability_Media = 'Windows Server 2012'
        },
        @{
            Role = @{
                Workstation = @{}
                DomainMember = @{}
            }
            NodeName = 'CHDBA2016'
            Network = @(
                @{
                    DnsServerAddress = '10.0.0.1'
                    NetAdapterName = 'CHICAGO'
                    SwitchName = 'CHICAGO'
                    IPAddress = '10.0.0.13/24'
                    DefaultGatewayAddress = '10.0.0.1'
                }
            )
            Lability_Media = 'Windows Server 2016'
        },
        @{
            Lability_BootDelay = 60
            Lability_Media = 'Windows Server 2016'
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
                    SourcePath = '\\CHDC01\Resources\SQL Server 2019'
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
                    SourcePath = '\\CHDC01\Resources\SQL Server 2019'
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
            Lability_Media = 'Windows Server 2016'
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
                    SourcePath = '\\CHDC01\Resources\SQL Server 2019'
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
            Lability_Media = 'Windows Server 2016'
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
                    SourcePath = '\\CHDC01\Resources\SQL Server 2019'
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
            Lability_Media = 'Windows Server 2016'
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
                    SourcePath = '\\CHDC01\Resources\SQL Server 2019'
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
            Lability_Media = 'Windows Server 2016'
        }
    )
    NonNodeData = @{
        Lability = @{
            Module = @(
                @{
                    RequiredVersion = '5.4.0'
                    Name = 'Pester'
                },
                @{
                    RequiredVersion = '1.7.4.4'
                    Name = 'PoshRSJob'
                },
                @{
                    RequiredVersion = '21.1.18256'
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
                    RequiredVersion = '4.1.6'
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
                    RequiredVersion = '9.1.0'
                    Name = 'ComputerManagementDsc'
                },
                @{
                    RequiredVersion = '9.0.0'
                    Name = 'NetworkingDsc'
                },
                @{
                    RequiredVersion = '6.5.0'
                    Name = 'ActiveDirectoryDsc'
                },
                @{
                    RequiredVersion = '3.0.0'
                    Name = 'DnsServerDsc'
                },
                @{
                    RequiredVersion = '1.1.1'
                    Name = 'FileSystemDsc'
                },
                @{
                    RequiredVersion = '2.8.0.0'
                    Name = 'xWindowsUpdate'
                },
                @{
                    RequiredVersion = '2.1.0'
                    Name = 'FailoverClusterDsc'
                },
                @{
                    RequiredVersion = '9.1.0'
                    Name = 'xPSDesiredStateConfiguration'
                },
                @{
                    RequiredVersion = '16.6.0'
                    Name = 'SqlServerDsc'
                }
            )
            Resource = @(
                @{
                    UseFolder = $true
                    Filename = 'NDP451-KB2858728-x86-x64-AllOS-ENU.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.5.1'
                    Uri = 'https://download.microsoft.com/download/1/6/7/167F0D79-9317-48AE-AEDB-17120579F8E2/NDP451-KB2858728-x86-x64-AllOS-ENU.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'NDP452-KB2901907-x86-x64-AllOS-ENU.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.5.2'
                    Uri = 'https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'NDP46-KB3045557-x86-x64-AllOS-ENU.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.6'
                    Uri = 'https://download.microsoft.com/download/6/F/9/6F9673B1-87D1-46C4-BF04-95F24C3EB9DA/enu_netfx/NDP46-KB3045557-x86-x64-AllOS-ENU_exe/NDP46-KB3045557-x86-x64-AllOS-ENU.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'NDP461-KB3102436-x86-x64-AllOS-ENU.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.6.1'
                    Uri = 'https://download.microsoft.com/download/E/4/1/E4173890-A24A-4936-9FC9-AF930FE3FA40/NDP461-KB3102436-x86-x64-AllOS-ENU.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'ndp462-kb3151800-x86-x64-allos-enu.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.6.2'
                    Uri = 'https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/80b431456d8866ebe053eb8b81a168b3/ndp462-kb3151800-x86-x64-allos-enu.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'ndp47-kb3186497-x86-x64-allos-enu.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.7'
                    Uri = 'https://download.visualstudio.microsoft.com/download/pr/2dfcc711-bb60-421a-a17b-76c63f8d1907/e5c0231bd5d51fffe65f8ed7516de46a/ndp47-kb3186497-x86-x64-allos-enu.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'ndp471-kb4033342-x86-x64-allos-enu.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.7.1'
                    Uri = 'https://download.visualstudio.microsoft.com/download/pr/4312fa21-59b0-4451-9482-a1376f7f3ba4/9947fce13c11105b48cba170494e787f/ndp471-kb4033342-x86-x64-allos-enu.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'ndp472-kb4054530-x86-x64-allos-enu.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.7.2'
                    Uri = 'https://download.visualstudio.microsoft.com/download/pr/1f5af042-d0e4-4002-9c59-9ba66bcf15f6/089f837de42708daacaae7c04b7494db/ndp472-kb4054530-x86-x64-allos-enu.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'ndp48-x86-x64-allos-enu.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.8'
                    Uri = 'https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'ndp481-x86-x64-allos-enu.exe'
                    Checksum = ''
                    Id = 'NET Framework 4.8.1'
                    Uri = 'https://download.visualstudio.microsoft.com/download/pr/6f083c7e-bd40-44d4-9e3f-ffba71ec8b09/3951fd5af6098f2c7e8ff5c331a0679c/ndp481-x86-x64-allos-enu.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'SSMS-Setup-ENU.exe'
                    Checksum = ''
                    Id = 'SQL Server Management Studio 16.5.3'
                    Uri = 'https://download.microsoft.com/download/9/3/3/933EA6DD-58C5-4B78-8BEC-2DF389C72BE0/SSMS-Setup-ENU.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'SSMS-Setup-ENU.exe'
                    Checksum = ''
                    Id = 'SQL Server Management Studio 17.9.1'
                    Uri = 'https://download.microsoft.com/download/D/D/4/DD495084-ADA7-4827-ADD3-FC566EC05B90/SSMS-Setup-ENU.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'SSMS-Setup-ENU.exe'
                    Checksum = ''
                    Id = 'SQL Server Management Studio 18.12.1'
                    Uri = 'https://download.microsoft.com/download/8/a/8/8a8073d2-2e00-472b-9a18-88361d105915/SSMS-Setup-ENU.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'SSMS-Setup-ENU.exe'
                    Checksum = ''
                    Id = 'SQL Server Management Studio 19.3'
                    Uri = 'https://download.microsoft.com/download/7/7/3/7738e337-ed99-40ea-b8ae-f639162c83c3/SSMS-Setup-ENU.exe'
                },
                @{
                    UseFolder = $true
                    Filename = 'SSMS-Setup-ENU.exe'
                    Checksum = ''
                    Id = 'SQL Server Management Studio 20.2'
                    Uri = 'https://download.microsoft.com/download/9/b/e/9bee9f00-2ee2-429a-9462-c9bc1ce14c28/SSMS-Setup-ENU.exe'
                },
                @{
                    Id = 'SQL Server 2012'
                    Filename = 'en_sql_server_2012_developer_edition_x86_x64_dvd_813280.iso'
                    Checksum = ''
                    Uri = 'https://myvs.download.prss.microsoft.com/dbazure/en_sql_server_2012_developer_edition_x86_x64_dvd_813280.iso?t=f30c5053-bee2-4622-b1f8-e78ddd6b5ae0&P1=1721391408&P2=601&P3=2&P4=W45rX79oT9ft3pHGmMo4EvdHKGCoWH%2bswE0IxEt05Eewk0K3uGzxWtGOO67dobdlJHV4XUenlcBdLAXyKSu%2bi5PjM6yGvoIgqXRJAwRyoY5dl42wRT4Zx3UcRY1oJXtStZM5te6njBY%2bIecZ3qeAVz97MhGtk%2fY47jOj540Aq17ef%2f7q2pv8AC5VLGKPi8U3RzjajwQJvl9oTwaD%2f7svPgHTO4VS5MoX5LQxpdmdgutabZHwcnMwvpI5vEcsYlXufzNnNSHIzfSeVX85uncy3VR7YzPQjs9Iy8FpKhcIuu1yPumgcTaPMnC42RzSzt6HCjnpiCi99a46u%2ffawrQbrA%3d%3d&su=1'
                    UseFolder = $true
                    Expand = $true
                },
                @{
                    Id = 'SQL Server 2014'
                    Filename = 'en_sql_server_2014_developer_edition_x64_dvd_3940406.iso'
                    Checksum = ''
                    Uri = 'https://myvs.download.prss.microsoft.com/dbazure/en_sql_server_2014_developer_edition_x64_dvd_3940406.iso?t=93490e4a-f779-4a3c-a159-8b5cdb4e48c7&P1=1721391477&P2=601&P3=2&P4=lyhUBl73YHoL43XApoe%2f3eORDYiJGNUEhVdc5SxInRPmxN42hQ74F6RPR0zhsxe8p2nMBWl%2fNCq8UC4YSVCYVOtPyb4SN6AYJKBY7nTkbEtP1PxRIaBP7e8sH%2bICwZDRY7ksAGgSiYvfH4a3P1gwfL48AciOf6nrYmP08DjfCOWQSh2YR18B%2b7GtnHVZ8e3nj375GP3KTI18ARTC6Kdq%2fb0WtQwQJkgIXPMm0Gwbm%2bo8v8u72MfgAX1OA3jd2hFLdp34Bm8UlDTlwq4uytgvf3rWakG0E0vCCbYuacxlIhdIiJTZdT6W8ik7cpdROY8hAHAHIc0XT3%2ffRNHlFUfB6Q%3d%3d&su=1'
                    UseFolder = $true
                    Expand = $true
                },
                @{
                    Id = 'SQL Server 2016'
                    Filename = 'en_sql_server_2016_developer_x64_dvd_8777069.iso'
                    Checksum = ''
                    Uri = 'https://myvs.download.prss.microsoft.com/dbazure/en_sql_server_2016_developer_x64_dvd_8777069.iso?t=c2bf9840-cb90-4c48-ae85-7db3850fccd0&P1=1721391502&P2=601&P3=2&P4=0qHwpQo8ozfFgefl1rEERdcJFbBMDe5jma4Do%2btBlxL%2bakiU2fX2%2fB6IwfFjfPUUvYIhqqTI18T6TlxaGv%2bsxQaTYzAE3FkO0W1lr5gzx3z71nMVvuNdV3kV6U5nABfcS2LrjTIW7EW7EC4ZlYzUHZT8vM1yCI4oUmbew3iTR6WOtJq3Bl9IbNC3vNFI1KHpApHziJa5GyGouASSoWb8JNKczj5Oq8fywaPuDSF3CB2y1hiBwHIpkFd5dn2hPw2R62USmryIWX8MdnczSNELQR0Ug9J2nKHAR7qso2lzYPPc8JFwfnke1WrgHaQqVuvaHEqBVgm7XqOUwKRQffgJgw%3d%3d&su=1'
                    UseFolder = $true
                    Expand = $true
                },
                @{
                    Id = 'SQL Server 2019'
                    Filename = 'en_sql_server_2019_developer_x64_dvd_baea4195.iso'
                    Checksum = ''
                    Uri = 'https://myvs.download.prss.microsoft.com/dbazure/en_sql_server_2019_developer_x64_dvd_baea4195.iso?t=1fe42426-3f14-45de-8f1f-ec0069114d2a&P1=1721391521&P2=601&P3=2&P4=WsYuOkH5vrKsvQx9PFW3YR2IjMCHod2mSyUlpfJjLQqfSHZ0MZssQTuRsWJCKUOFwnhxdIIjI6O7nhC5a1o%2b5XcTFw6WtcVYJf%2fyuqPzHp138URQw4Qhh0O5KZGXeRuBamGg6ufxbJdIi3oM%2fILWXA6ngWnkBd%2bXGLHSKcJuV4C4iezt%2f2rxFBj5tOltw2488UUeoe59M2Av4gh6fuAICNuUaMyFleqaggD78joVDCvGHAeq%2fVyR4Nnpk9cykm%2fVLivEXYP21%2fJCzo9nSc8Fyomc5dOLdM6owIab%2fbT%2bDvzybPS2yMCzn4Mp6HaC7FgG3F1%2boi15DE4ABQ9OLFlq%2bg%3d%3d&su=1'
                    UseFolder = $true
                    Expand = $true
                },
                @{
                    Id = 'SQL Server 2022'
                    Filename = 'enu_sql_server_2022_developer_edition_x64_dvd_7cacf733.iso'
                    Checksum = ''
                    Uri = 'https://myvs.download.prss.microsoft.com/dbazure/enu_sql_server_2022_developer_edition_x64_dvd_7cacf733.iso?t=9633b1f6-805a-4d5b-949b-ca1fd1fbaa82&P1=1721391538&P2=601&P3=2&P4=RzBCD4hizfUfrSCMvdUlCE5lDbdTvyrad4EOhCNlOCxpvEcXyEzZ8iqjDW3qaoEIOxGRM04M03qvRlv4cMhDnGaDQMCA9jD%2bkLkoXg0p2RmYFuYc%2fJVzxc5wpbewmyS0plUCxSRqSLj7I7bVFEIm9X6GyBtVgt9J7RRlWtYCE7vVZWfCSfm%2bIthHNHHGPBwLLr4IER%2bWgEoJ9e04MTfmP44R6qMVHTtaudzJBsUZcf8mKEGEazr5Nlhv9A%2f4AcQofP5r9YQXijO9lm3tGfJa9GzTy6QHUl37ZdotJ%2b%2bWwVjosvltgv%2f79cH%2bdA5ukwyG%2bzV7TvKhHnlVBsZ5PImt6g%3d%3d&su=1'
                    UseFolder = $true
                    Expand = $true
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
                    Filename = '9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    Id = 'Windows Server 2012'
                    Architecture = 'x64'
                    Checksum = ''
                    MediaType = 'ISO'
                    Uri = 'http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO'
                    UseFolder = $true
                    CustomData = @{
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                        CustomBootStrap = @(
                            'NET USER Administrator /active:yes',
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force',
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force',
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                    }
                    Description = 'Windows Server 2012'
                    ImageName = 2
                    OperatingSystem = 'Windows'
                    Hotfixes = @(
                        @{
                            Id = 'W2K12-KB3191565-x64.msu'
                            Uri = 'https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/W2K12-KB3191565-x64.msu'
                        }
                    )
                },
                @{
                    Filename = '9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO'
                    Id = 'Windows Server 2012 R2'
                    Architecture = 'x64'
                    Checksum = ''
                    MediaType = 'ISO'
                    Uri = 'https://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO'
                    UseFolder = $true
                    CustomData = @{
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                        CustomBootStrap = @(
                            'NET USER Administrator /active:yes',
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force',
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force',
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                    }
                    Description = 'Windows Server 2012 R2'
                    ImageName = 2
                    OperatingSystem = 'Windows'
                    Hotfixes = @(
                        @{
                            Id = 'Win8.1AndW2K12R2-KB3191564-x64.msu'
                            Uri = 'https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu'
                        }
                    )
                },
                @{
                    Filename = 'Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO'
                    Id = 'Windows Server 2016'
                    Architecture = 'x64'
                    Checksum = ''
                    MediaType = 'ISO'
                    Uri = 'https://software-static.download.prss.microsoft.com/pr/download/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO'
                    UseFolder = $true
                    CustomData = @{
                        MinimumDismVersion = '10.0.0.0'
                        CustomBootStrap = @(
                            'NET USER Administrator /active:yes',
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force',
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force',
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                    }
                    Description = 'Windows Server 2016'
                    ImageName = 2
                    OperatingSystem = 'Windows'
                    Hotfixes = @()
                },
                @{
                    Filename = '17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso'
                    Id = 'Windows Server 2019'
                    Architecture = 'x64'
                    Checksum = ''
                    MediaType = 'ISO'
                    Uri = 'https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso'
                    UseFolder = $true
                    CustomData = @{
                        MinimumDismVersion = '10.0.0.0'
                        CustomBootStrap = @(
                            'NET USER Administrator /active:yes',
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force',
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force',
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                    }
                    Description = 'Windows Server 2019'
                    ImageName = 2
                    OperatingSystem = 'Windows'
                    Hotfixes = @()
                },
                @{
                    Filename = 'SERVER_EVAL_x64FRE_en-us.iso'
                    Id = 'Windows Server 2022'
                    Architecture = 'x64'
                    Checksum = ''
                    MediaType = 'ISO'
                    Uri = 'https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso'
                    UseFolder = $true
                    CustomData = @{
                        MinimumDismVersion = '10.0.0.0'
                        CustomBootStrap = @(
                            'NET USER Administrator /active:yes',
                            'Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force',
                            'Enable-PSRemoting -SkipNetworkProfileCheck -Force',
                            '&schtasks.exe /create /tn "NlaSvcFix" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\NlaSvcFix.ps1 >> %SYSTEMDRIVE%\BootStrap\NlaSvcFix.log" /sc "ONSTART" /ru "System" /f',
                            '&schtasks.exe /create /tn "TriggerDsc" /tr "powershell.exe %SYSTEMDRIVE%\BootStrap\TriggerDsc.ps1 >> %SYSTEMDRIVE%\BootStrap\TriggerDsc.log" /sc "ONSTART" /ru "System" /f'
                        )
                        WindowsOptionalFeature = @(
                            'NetFx3',
                            'TelnetClient'
                        )
                    }
                    Description = 'Windows Server 2022'
                    ImageName = 2
                    OperatingSystem = 'Windows'
                    Hotfixes = @()
                }
            )
        }
    }
}
