# TODO

## Newer

- Set up read-routing lists.
- Use a different service account for each cluster (optionally MSA or gMSA).
- Enforce availability replica group owner of sa.
- Investigate applying cluster hotfixes.
  - KB2770917 (Windows 8 and Windows Server 2012 update rollup: November 2012)
  - KB2838664 (A HotFix that enables SQL Server availability groups support in Windows Server 2012 is available)
  - KB2838043 (Can't access a resource that is hosted on a Windows Server 2012-based failover cluster)
  - KB2870270 (Update that improves cloud service provider resiliency in Windows Server 2012)
  - KB2869923 (The Physical Disk resource for a Cluster Shared Volume may not come online during backup)
- Add fileshare witness for Windows 2016
- Add reverse lookups for AG1L, AG2L, C1, C2, and computers
- Set cluster settings:
  - CrossSubnetDelay is set to 1000 instead of 4000
  - CrossSubnetThreshold is set to 5 instead of 10
  - RouteHistoryLength is set to 10 instead of 20
- Set Power Plan to High Performance?
- Disable SQL/Windows Telemetry
- Disable USO_UxBroker_Display
- Set file growths to 128MB
- Set indirect checkpoints?
- Add SeManageVolumePrivilege and SeLockMemoryPrivilege
- Add SPNs?
- Disable sa password policy
- Enable remote DAC
- Add another temp file
- Add trace flags
  - Trace flag 3226 is not set
  - Trace flag 1117 is not set
  - Trace flag 1118 is not set
  - Trace flag 8048 is not set

## Older

- Try removing the MaxCacheTTL etc and instead use xDnsServer.
- Add node to cluster can have an error which triggers a 15 minute wait.
- Would it save time to install SQL while waiting for the domain to join? Change SQL to use AD accounts?
- Stop the SQL Server AG install unless all nodes are joined (it may fail if the second subnet of nodes isn't in first)
- Set up WSUS registry keys. Set up WSUS server.
  - https://www.rootusers.com/install-and-configure-windows-server-update-services-wsus/
  - https://devblogs.microsoft.com/scripting/installing-wsus-on-windows-server-2012/
  - https://github.com/PowerShell/xWindowsUpdate
- Format D: for SQL
- Create MSA accounts
  - Add SecurityPolicyDsc permissions
- Create RDCMan file
