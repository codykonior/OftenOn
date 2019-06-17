# OftenOn PowerShell Module by Cody Konior

![OftenOn logo][1]

[![Build status](https://ci.appveyor.com/api/projects/status/smdxnxpi6c006son?svg=true)](https://ci.appveyor.com/project/codykonior/oftenon)

Read the [CHANGELOG][3]

## Description

OftenOn is a Lability/Hyper-V/Desired State Configuration wrapper which builds and configures five-node no-storage multi-subnet
Windows Server Failover Cluster(s) with SQL Server Availability Groups.

It was designed specifically to be compatible with Windows Server 2012 (WS2012) and SQL Server 2012 (SQL2012) and for testing
migration scenarios to higher clusters (a SQL2012 cross-cluster migration) and higher SQL Server versions (a SQL 2017 upgrade
followed by a Distributed Availability Group migration).

## Installation

- `Install-Module OftenOn`

## Major functions

- `Set-OftenOnLab`
- `New-OftenOnLab`
- `Stop-OftenOnLab`
- `Start-OftenOnLab`
- `Remove-OftenOnLab`

## Demo

![Building the OftenOn Lab][11]

`Set-OftenOnLab -ConfigurationName X` lets you switch to different migration scenarios.
- `Default` is the original OftenOn, a five-node no-storage multi-subnet WSFC cluster with WS2012 and SQL2012.
- `CrossClusterMigration` is a WS2012 and SQL2012 cluster, with a second WS2016 and SQL2012 cluster. You can use this to practice
SQL2012 cross-cluster migrations.
- `Upgrade` is a WS2012 and SQL2012 cluster, with a second WS2016 and SQL2017 cluster. You can use this to practice upgrading
SQL2012 to SQL2017 and then setting up a Distributed Availability Group to migrate from one cluster to another.
- `DAG` is a WS2012 and SQL2017 cluster, with a second WS2016 and SQL2017 cluster. You can use this to practice just setting up
a Distributed Availability Group and migrating from one cluster to another.

Then execute `New-OftenOnLab`.

It takes time on the first run to download about 10GB of Evaluation ISOs from Microsoft. After this though each time the lab is
destroyed and competely recreated takes 45-60 minutes. You'll know it's done when all the VMs go to the login screen.

![Show the OftenOn VMs][12]

Then remote in yourself! Remote Desktop from your machine should work to the short computer names (e.g. CHDC01) via IPv6 but it may
not work on some configurations.

Username OFTENON\LocalAdministrator
Password Local2019!

## VM naming conventions

The VMs built are as follows:

- CHDC01 the domain controller in the Chicago subnet that also does routing for other subnets.
- CHWK01 a workstation in Chicago with .NET 4.7.2 and SSMS 18.1.
- SEC1N1 SEC1N2 SEC1N3 are three nodes of the C1 cluster in the Seattle subnet.
- DAC1N1 DAC1N2 are two nodes of the C1 cluster in the Dallas subnet.

(and for the non-default scenarios)
- SEC2N1 SEC2N2 SEC2N3 are three nodes of the C2 cluster in the Seattle subnet.
- DAC2N1 DAC2N2 are two nodes of the C2 cluster in the Dallas subnet.

The C1 cluster has an Availability Group (AG1), a listener (AG1L), and 4 databases (AG1DBx). It's all sync'd to Dallas and ready
to failover for your testing! C2 cluster usually doesn't have an Availability Group because setting that up is part of doing your
migration. Where it is required, I recomment set it up like so:

- Availability Group AG2
- Listener AG2L
- IP Addresses 10.0.1.131/255.255.255.0 and 10.0.2.131/255.255.255.0

And if you use a Distributed Availability Group:

- DAG1 (covering AG1 and AG2)

## Other notes

All VMs have WMF 5.1 installed. There's a couple resources (like SQL patches and the .NET 4.7.2 updater) on \\CHDC01\Resources.
Those aren't installed everywhere because that's part of the fun of the lab - exploring various issues with and without them.
It's also loaded with all my other PowerShell modules.

![Show the OftenOn AG][13]

[1]: Images/oftenon.ai.svg
[3]: CHANGELOG.md

[11]: Images/oftenon1.gif
[12]: Images/oftenon2.gif
[13]: Images/oftenon3.gif
