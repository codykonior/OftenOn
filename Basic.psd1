@{
    AllNodes    = @(
        @{
            NodeName                = '*';

            Lability_ProcessorCount = 2;
            Lability_StartupMemory  = 2GB;
            Lability_Media          = '2012R2_x64_Standard_EN_V5_1_Eval';
            Lability_HardDiskDrive  = @(
                @{
                    Type = 'Dynamic'
                    Generation       = 'VHDX';
                    MaximumSizeBytes = 127GB;
                }
            ) 
            # Disk isn't online, partitioned or formatted

            Thumbprint              = "5940D7352AB397BFB2F37856AA062BB471B43E5E";
            CertificateFile         = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer";
            PSDscAllowDomainUser    = $true;

            DefaultGateway          = '10.0.0.1';
            PrefixLength            = 24;
            DnsServerAddress        = '10.0.0.1'; # But shouldn't be on WAN link
            DomainName              = 'codykonior.com';

        }

        @{
            NodeName            = 'DC';
            IPAddress           = '10.0.0.1';
            # DnsServerAddress    = '127.0.0.1';

            Role                = 'DC';
        }
        @{
            NodeName  = 'NODE1';
            IPAddress = '10.0.0.11';

            Role      = 'WSFC';
        }
        @{
            NodeName  = 'NODE2';
            IPAddress = '10.0.0.12';
            Role      = 'WSFC';
        }
        @{
            NodeName  = 'W1';
            IPAddress = '10.0.0.11';
        }

        # External switch didn't have the management stuff turned on? (fixed)
        # DNS settings got mixed between first and second network card (fixed)
        # If you manually reboot a VM before it's set up, it will be broken for a while but work fine later
        # If you wait for a VM for hours until the DC comes up, it will start working fine
        # Configure and enable, NAT, public is Ethernet
        # That gets the IP pinging working but DNS doesn't

    );
    NonNodeData = @{
        Lability = @{
            Network = @(
                );
        };
    };
};
