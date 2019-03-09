# TODO

Nodes really need internet access.

Try removing the MaxCacheTTL etc and instead use xDnsServer.

Add node to cluster can have an error which triggers a 15 minute wait.

Set up read routing list (needs SqlServerDsc merge first)

Add a command to snapshot OftenOnLab, and restore the snapshot, based on Lability stuff
    Checkpoint-OftenOnLab
    Reset-OftenOnLab

Would it save time to install SQL while waiting for the domain to join? Change SQL to use AD accounts?

Stop the SQL Server AG install unless all nodes are joined (it may fail if the second subnet of nodes isn't in first)

Set up WSUS registry keys. Set up WSUS server.
    https://www.rootusers.com/install-and-configure-windows-server-update-services-wsus/
    https://devblogs.microsoft.com/scripting/installing-wsus-on-windows-server-2012/
    https://github.com/PowerShell/xWindowsUpdate

Format D: for SQL

Create MSA accounts
    Add SecurityPolicyDsc permissions

Create RDCMan file
