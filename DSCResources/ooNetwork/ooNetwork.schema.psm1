Configuration ooNetwork {
    param(
        [Parameter(Mandatory)]
        $Node
    )
    
    if ($node.ContainsKey('Network')) {
        for ($i = 0; $i -lt $node.Network.Count; $i++) {
            $network = $node.Network[$i]

            NetAdapterName "Rename$($network.NetAdapterName)" {
                NewName = $network.NetAdapterName
                MacAddress = $node.Lability_MACAddress[$i].Replace(':', '-')
            }

            if ($network.ContainsKey('IPAddress')) {
                IPAddress "SetIPAddress$($network.NetAdapterName)" {
                    AddressFamily = 'IPv4'
                    InterfaceAlias = $network.NetAdapterName
                    IPAddress = $network.IPAddress
                    DependsOn = "[NetAdapterName]Rename$($network.NetAdapterName)"
                }
            }

            if ($network.ContainsKey('DefaultGatewayAddress')) {
                DefaultGatewayAddress "SetDefaultGatewayAddress$($network.NetAdapterName)" {
                    AddressFamily = 'IPv4'
                    InterfaceAlias = $network.NetAdapterName
                    Address = $network.DefaultGatewayAddress
                    DependsOn = "[NetAdapterName]Rename$($network.NetAdapterName)"
                }
            }

            if ($network.ContainsKey('DnsServerAddress')) {
                DnsServerAddress "SetDnsServerAddress$($network.NetAdapterName)" {
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $network.NetAdapterName
                    Address        = $network.DnsServerAddress
                    DependsOn = "[NetAdapterName]Rename$($network.NetAdapterName)"
                }
            }

            DnsConnectionSuffix "SetDnsConnectionSuffix$($network.NetAdapterName)" {
                InterfaceAlias           = $network.NetAdapterName
                ConnectionSpecificSuffix = $node.FullyQualifiedDomainName
                DependsOn = "[NetAdapterName]Rename$($network.NetAdapterName)"
            }
        }
    }
}

