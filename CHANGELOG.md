# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
-  The new bootstrap scheduled task removes itself once DSC reports that it is
   complete. This prevents any of your own customisations from possibly being
   overwritten on a later reboot.

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
