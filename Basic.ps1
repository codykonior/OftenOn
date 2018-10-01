DC

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
    MembersToInclude = 'Admin';
    DependsOn        = '[xADUser]CodyAdmin';
}

xDnsServerForwarder "WAN Forwarder" {
    IsSingleInstance = "Yes";
    IPAddresses = "1.1.1.1";
    # DependsOn = '[WindowsFeature][DNS]';
}
