# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- None.

## [1.0.8] - 2018-10-30
### Changed
- If `Test-LabHostConfiguration` fails then run `StartLabHostConfiguration` then
  exit with an error. This is to force a reboot because it's too easy to continue
  at this stage and get more insidious errors.
