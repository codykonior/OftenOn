# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.5] - 2019-08-30
### Fixed
- Re-added missing header to OftenOn.psm1 which does version checksk
- DSC module version updates.

## [1.1.4] - 2019-06-20
### Fixed
- ISO checksum for SQL 2017.

## [1.1.3] - 2019-06-19
### Fixed
- Re-address the NlaSvc "this network is Public" issue with a startup script.
- Re-address the application of DSC configuration after reboot with another
  startup script.

## [1.1.2] - 2019-06-18
### Changed
- Updated dependent module numbers.

## [1.1.1] - 2019-06-17
### Changed
- Updated dependent module numbers.

## [1.1.0] - 2019-06-17
### Added
- Set-OftenOnLab can be used to alter what configuration New-OftenOnLab will
  create. Options are:
    Default (SQL 2012 on Windows 2012)
    CrossClusterMigration (2x clusters of SQL 2012 on Windows 2012)
    Upgrade (SQL 2012 on Windows 2012 and SQL 2017 on Windows 2016)
    DAG (SQL 2017 on Windows 2012 and SQL 2017 on Windows 2017)
- Windows 2016 support.

### Changed
- SQL patches are applied by default because a lot of the migrations require
  them.
- CHDC01 and CHWK01 are now Windows 2016. This makes life easier as we are
  only really interested in migration scenarios where SQL is on Windows 2012.
- The domain LAB is now called OFTENON. This bears no relation to any .com of
  the same name.
- SSMS 18.1.0 is installed by default. The previous two are still available.
- 4 databases are added to the Availability Group by default.
- Added version numbers to some non-DSC modules which are copied in. This is
  because Lability is caching the old versions.

### Fixed
- Internet access for machines inside the domain. This is critical for time sync
  which is critical for Windows 2016 support.
  If it doesn't work for you and you're on an old Windows 10 version like 1607,
  modify your Default Switch in Hyper-V manager to be an External switch. On
  newer Windows 10 it should just work without this.

## [1.0.21] - 2019-04-18
### Fixed
- Revert broken version.

## [1.0.19] - 2019-04-15
### Removed
- HackSql module is no longer installed by default in VMs as it can be flagged
  as an unwanted program by AV.

## [1.0.18] - 2019-04-04
### Changed
- Updated for latest DSC Resource Kit release.

## [1.0.17] - 2019-04-04
### Changed
- Updated for latest DSC Resource Kit release.

## [1.0.16] - 2019-04-03
### Changed
- VM startup memory reduced to 1GB so that builds are more consistent on a
  16GB laptop. This means BootOrder and BootDelay was no longer needed.

### Fixed
- The new bootstrap scheduled task removes itself once DSC reports that it is
  complete. This prevents any of your own customisations from possibly being
  overwritten on a later reboot.
- WAN adapter.

### Broken
- Desired state is never reached on CHDC01.

 VERBOSE: [CHDC01]:
 [[DnsServerAddress]SetDnsServerAddressDALLAS_HB::[ooNetwork]RenameNetwork]
 Test-TargetResource: DNS server addresses are not correct.
 Expected "", actual "127.0.0.1".


## [1.0.15] - 2019-03-09
### Changed
- Internet Explorer Enhanced Security Configuration is disabled by default.
- Passwords end with 2019 instead of 2018.
- All nodes now have internet access that go through the router/NAT on the
  DC. This is set up on the DC *after* the domain has been created. Doing
  this before the domain has been created stops it from being created and
  stops nodes from joining.
- There's a scheduled task which re-applies the Bootstrap DSC configuration
  on every boot. This is to make the initial configuration go faster and
  also results in better capturing of errors to the text logs.

### Notes
- After ISOs and others have been downloaded once, this now builds the lab
  in 56 minutes on my laptop. Here's the timing.

  00 minutes - MOFs compile and VMs get created.
  05 minutes - VMs start. CHDC01 domain creation starts.
  20 minutes - CHDC01 reboots followed by all other nodes as the pick up
               the new domain. SQL installs start.
  55 minutes - Finished.

### Added
- Stop-OftenOnLab has a new -TurnOff parameter which is faster.
- Remove-OftenOnLab now uses Stop-OftenLab -TurnOff and so runs faster.

### Broken
- The DC WAN adapter is now broken and has no internet access. I don't know why.

## [1.0.14] - 2019-02-27
### Fixed
- LCM DebugMode set to ForceModuleImport. This will massively speed up setup
  by not caching DSC responses from resources, which slows down joining the
  domain and setting up the cluster.

### Changed
- DSC resource module version number updates.
- Don't quit when the DSC modules are wrong. This is so you can still use
  Remove-OftenOnLab when things are out of date.

## [1.0.13] - 2019-02-13
### Changed
- Updated required version of modules, and give more errors upon load if the
  modules on disk are different to what is expected.
- Update to use SSMS 17.9.1.

## [1.0.12] - 2018-11-03
### Fixed
- Typo from previous version.

## [1.0.11] - 2018-11-02
### Changed
- Enable the TLS 1.2 in the session by default if it's not set. This is easier.

## [1.0.10] - 2018-11-02
### Added
- HackSql PowerShell module.
- 10s delay between booting each VM so this can run on 16GB laptops easier.
- Warning if you don't have TLS 1.2 enabled as it results in GitHub download
  errors.

## [1.0.9] - 2018-11-01
### Added
- Enable Mixed mode authentication by default.

## [1.0.9] - 2018-10-31
### Added
- Pester and DbSmo modules copied to servers.

## [1.0.8] - 2018-10-30
### Changed
- If `Test-LabHostConfiguration` fails then run `StartLabHostConfiguration` then
  exit with an error. This is to force a reboot because it's too easy to continue
  at this stage and get more insidious errors.
