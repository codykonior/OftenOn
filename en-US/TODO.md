
Add node to cluster can have an error which triggers a 15 minute wait.

TODO
    Use Test-LabHostConfiguration
    Remove router, simplifies to have it on the DC.
    Would it save time to install SQL while waiting for the domain to join? Change SQL to use AD accounts.
    Set which node is in sync/auto to start with
    Stop the SQL Server AG install unless all nodes are joined (it may fail if the second subnet of nodes isn't in first)
    Set up WSUS registry keys. Set up WSUS server
    Format D:
    Create MSA accounts
        Add SecurityPolicyDsc permissions
        Create RDCMan

    # Give two options, either IP Forwarding (no WAN) or
    Install-RemoteAccess -VpnType Vpn
    &netsh routing ip nat install
    $ExternalInterface = 'WAN'
    &netsh routing ip nat add interface $ExternalInterface
    &netsh routing ip nat set interface $ExternalInterface mode=full
    ^-- This seems to be enough even with IP forwarding disabled, also gives NAT
    But then you need to enable recursion, and add a forwarder to 1.1.1.1
    # $InternalInterface1 = 'LAN1'
    # $InternalInterface2 = 'LAN2'
    # cmd.exe /c 'netsh routing ip nat add interface $InternalInterface1'
    # cmd.exe /c 'netsh routing ip nat add interface $InternalInterface2'
    # xDnsServerForwarder "WAN Forwarder" {
    #     IsSingleInstance = "Yes";
    #     IPAddresses = "1.1.1.1";
    #     # DependsOn = '[WindowsFeature][DNS]';
    # }
