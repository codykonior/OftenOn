# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- None.

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
