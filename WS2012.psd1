@{
    AllNodes    = @(
        @{
            NodeName                          = "*"
            Lability_ProcessorCount           = 2
            Lability_StartupMemory            = 2GB
            Lability_Media                    = "Windows Server 2012 Standard Evaluation (Server with a GUI)"
            Lability_HardDiskDrive            = @(
                @{
                    Generation       = "VHDX"
                    MaximumSizeBytes = 100GB
                }
            )
            Lability_GuestIntegrationServices = $true
            # CertificateFile                   = ""
            # Thumbprint                        = ""
            PSDscAllowDomainUser              = $true

            DomainName                        = "lab.com"
            DnsServerAddress                  = "10.0.0.1"
        },

        @{
            NodeName            = "DC1"

            # Lability_MACAddress = ""
            Lability_SwitchName = @("LAN_10_0_0", "LAN_10_0_1", "LAN_10_0_2")
            NetworkAdapterName  = @("LAN_10_0_0", "LAN_10_0_1", "LAN_10_0_2")
            IPAddress           = @("10.0.0.1/24", "10.0.1.1/24", "10.0.2.1/24")
            DnsServerAddress    = @("127.0.0.1", "127.0.0.1", "127.0.0.1")
            Role                = "DomainController"
        },

        @{
            NodeName            = "C1N1"

            # Lability_MACAddress = ""
            Lability_SwitchName = @("LAN_10_0_1")
            NetworkAdapterName  = @("LAN")
            IPAddress           = @("10.0.1.11/24")
            GatewayAddress      = "10.0.1.1"

            Role                = "FirstClusterNode"

        },

        @{
            NodeName            = "C1N2"

            # Lability_MACAddress = ""
            Lability_SwitchName = @("LAN_10_0_1")
            NetworkAdapterName  = @("LAN")
            IPAddress           = @("10.0.1.12/24")
            GatewayAddress      = "10.0.1.1"
            Role                = "OtherClusterNode"
        }

        @{
            NodeName            = "C1N3"

            # Lability_MACAddress = ""
            Lability_SwitchName = @("LAN_10_0_2")
            NetworkAdapterName  = @("LAN")
            IPAddress           = @("10.0.2.12/24")
            GatewayAddress      = "10.0.2.1"
            Role                = "OtherClusterNode"
        }

    )
    NonNodeData = @{
        Lability = @{
            DSCResource = @(
                # If these aren't defined (the block is empty), it will hang
                # Not specifying FileSystem will make it download wrong versions from GitHub also
                # @{ Name = "PSDesiredStateConfiguration"; RequiredVersion = "1.1"; Provider = "FileSystem"; }
                @{ Name = "xPSDesiredStateConfiguration"; RequiredVersion = "8.4.0.0"; }
                @{ Name = "ComputerManagementDsc"; RequiredVersion = "5.2.0.0"; }
                @{ Name = "NetworkingDsc"; RequiredVersion = "6.1.0.0"; }
                @{ Name = "xActiveDirectory"; RequiredVersion = "2.21.0.0"; }
                # The version on PowerShellGallery is too old, we need > 1.10.0.0
                @{ Name = "xFailOverCluster"; Provider = 'GitHub'; Owner = 'PowerShell'; Branch = 'dev'; }
                @{ Name = "xDnsServer"; RequiredVersion = "1.11.0.0"; }
                @{ Name = "xRemoteDesktopAdmin"; RequiredVersion = "1.1.0.0"; }
            )

            Network     = @(
                @{ Name = "LAN_10_0_0"; Type = "Internal"; }
                @{ Name = "LAN_10_1_0"; Type = "Internal"; }
                @{ Name = "LAN_10_2_0"; Type = "Internal"; }
            )

            Media       = @(
                @{
                    # https://www.microsoft.com/en-in/evalcenter/evaluate-windows-server-2012
                    Id              = "Windows Server 2012 Standard Evaluation (Server with a GUI)"
                    Filename        = "9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO"
                    Architecture    = "x64"
                    Uri             = "http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO"
                    Checksum        = "8503997171F731D9BD1CB0B0EDC31F3D"
                    Description     = "Windows Server 2012 Standard Evaluation (Server with a GUI)"
                    MediaType       = "ISO"
                    ImageName       = "Windows Server 2012 Standard Evaluation (Server with a GUI)"
                    OperatingSystem = "Windows"
                    Hotfixes        = @(
                        @{
                            # WMF 5.1 for Windows Server 2012
                            Id  = "W2K12-KB3191565-x64.msu"
                            # Filename and Checksum are ignored
                            # Filename = "W2K12-KB3191565-x64.msu"
                            # Checksum = "E978C87841BAED49FB68206DF5E1DF9C"
                            Uri = "https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/W2K12-KB3191565-x64.msu"
                        }
                    )
                    CustomData      = @{
                        # CustomBootStrap = @("Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue;")
                        CustomBootStrap = @("Set-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell -Name ExecutionPolicy -Value RemoteSigned -Force; #306")
                    }
                }
            )
        }
    }
}
