Configuration Basic {
    param (
    )
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName NetworkingDsc
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xDnsServer

    node $AllNodes.NodeName {
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true;
            AllowModuleOverwrite = $true;
            ConfigurationMode    = 'ApplyOnly';
            CertificateID        = $node.Thumbprint;
        }

        IPAddress 'PrimaryIPAddress' {
            IPAddress      = $node.IPAddress;
            InterfaceAlias = "Ethernet";
            AddressFamily  = "IPV4";
        }

        DefaultGatewayAddress 'PrimaryDefaultGateway' {
            InterfaceAlias = "Ethernet";
            Address        = $node.DefaultGateway;
            AddressFamily  = "IPV4";
        }

        DnsServerAddress 'PrimaryDNSClient' {
            Address        = $node.DnsServerAddress;
            InterfaceAlias = "Ethernet";
            AddressFamily  = "IPV4";
        }

        Firewall 'FPS-ICMP4-ERQ-In' {
            Name        = 'FPS-ICMP4-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)';
            Description = 'Echo request messages are sent as ping requests to other nodes.';
            Direction   = 'Inbound';
            Action      = 'Allow';
            Enabled     = 'True';
            Profile     = 'Any';
        }

        Firewall 'FPS-ICMP6-ERQ-In' {
            Name        = 'FPS-ICMP6-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)';
            Description = 'Echo request messages are sent as ping requests to other nodes.';
            Direction   = 'Inbound';
            Action      = 'Allow';
            Enabled     = 'True';
            Profile     = 'Any';
        }
    }

    node $AllNodes.Where({ $_.Role -in 'DC' }).NodeName {
        ## Flip credential into username@domain.com
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);

        Computer 'HostName' {
            Name = $node.NodeName;
        }

        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'AD-Domain-Services',
                'GPMC',
                'RSAT-AD-Tools',

                'Routing',
                'RSAT-RemoteAccess',

                'DNS',
                'RSAT-DNS-Server'
            )) {
            WindowsFeature $feature.Replace('-', '') {
                Ensure               = 'Present';
                Name                 = $feature;
                IncludeAllSubFeature = $true;
            }
        }

        xADDomain 'ADDomain' {
            DomainName                    = $node.DomainName;
            SafemodeAdministratorPassword = $SafeModeCredential;
            DomainAdministratorCredential = $DomainAdministratorCredential;
            DependsOn                     = '[WindowsFeature]ADDomainServices';
        }

        xADUser CodyAdmin {
            DomainName  = $node.DomainName;
            UserName    = 'CodyAdmin';
            Description = 'Domain Admin';
            Password    = $DomainUserCredential;
            Ensure      = 'Present';
            DependsOn   = '[xADDomain]ADDomain';
        }

        xADGroup DomainAdmins {
            GroupName        = 'Domain Admins';
            MembersToInclude = 'CodyAdmin';
            DependsOn        = '[xADUser]CodyAdmin';
        }

        xDnsServerForwarder "WAN Forwarder" {
            IsSingleInstance = "Yes";
            IPAddresses = "192.168.1.1";
            # DependsOn = '[WindowsFeature][DNS]';
        }
    }

    node $AllNodes.Where( {$_.Role -notin 'DC'}).NodeName {
        ## Flip credential into username@domain.com
        $upn = '{0}@{1}' -f $Credential.UserName, $node.DomainName;
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($upn, $Credential.Password);

        Computer 'DomainMembership' {
            Name       = $node.NodeName;
            DomainName = $node.DomainName;
            Credential = $domainCredential;
        }
    } #end nodes DomainJoined

} #end Configuration Example
