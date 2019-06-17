# OftenOn PowerShell Module by Cody Konior

![OftenOn logo][1]

[![Build status](https://ci.appveyor.com/api/projects/status/smdxnxpi6c006son?svg=true)](https://ci.appveyor.com/project/codykonior/oftenon)

Read the [CHANGELOG][3]

## Description

OftenOn is my latest project to spin up a 5-node multi-subnet Availability Group on SQL Server 2012 and Windows Server 2012 with one
command. How? Through Hyper-V, Desired State Configuration, the `Lability` PowerShell module, and an immense amount of work.

## Installation

- `Install-Module OftenOn`

## Major functions

- `New-OftenOnLab`
- `Stop-OftenOnLab`
- `Start-OftenOnLab`
- `Remove-OftenOnLab`

## Demo

![Building the OftenOn Lab][11]

It takes time on the first run to download about 10GB of Evaluation ISOs from Microsoft. After this though each time the lab is
destroyed and competely recreated takes 45-60 minutes. You'll know it's done when all the VMs go to the login screen.

![Show the OftenOn VMs][12]

Then remote in yourself! Remote Desktop from your machine should work to the short computer names (e.g. CHDC01) via IPv6 but it may
not work on some configurations.

Username OFTENON\LocalAdministrator
Password Local2019!

The VMs built are as follows:

- CHDC01 the domain controller in the Chicago subnet that also does routing for other subnets.
- CHWK01 a workstation in Chicago with .NET 4.7.2 and SSMS 17.9.1.
- SEC1N1 SEC1N2 SEC1N3 are three nodes of the C1 cluster in the Seattle subnet.
- DAC1N1 DAC1N2 are two nodes of the C1 cluster in the Dallas subnet.

The C1 cluster has an Availability Group (AG1), a listener (AG1L), and a database (AG1DBx). It's all sync'd to Dallas and ready
to failover for your testing!

All VMs have WMF 5.1 installed. There's a couple resources (like SQL patches and the .NET 4.7.2 updater) on \\CHDC01\Resources.
Those aren't installed everywhere because that's part of the fun of the lab - exploring various issues with and without them.
It's also loaded with all my other PowerShell modules.

![Show the OftenOn AG][13]

[1]: Images/oftenon.ai.svg
[3]: CHANGELOG.md

[11]: Images/oftenon1.gif
[12]: Images/oftenon2.gif
[13]: Images/oftenon3.gif
