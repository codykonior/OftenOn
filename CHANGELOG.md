# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- None.

## [1.0.15] - 2019-03-09
### Changed
- Internet Explorer Enhanced Security Configuration is disabled by default.

### Fixed
- Network bind order for the domain controller changed to prefer CHICAGO.
  Anecdotally (on one test) this has sped up domain creation and how fast
  members pick up the new domain also.

### Added
- Stop-OftenOnLab has a new -TurnOff parameter which is faster.
- Remove-OftenOnLab now uses Stop-OftenLab -TurnOff and so runs faster.

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
