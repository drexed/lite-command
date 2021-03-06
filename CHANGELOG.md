# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2021-02-04
### Changed
- Add failed_steps to procedure

## [1.1.1] - 2019-12-08
### Changed
- Improve procedure error merging

## [1.1.0] - 2019-12-06
### Added
- Added procedure support for running multiple commands

## [1.0.10] - 2019-12-21
### Added
- Added Ruby 2.7 support
### Removed
- Removed generator empty directory check

## [1.0.9] - 2019-12-20
### Removed
- Removed lite-command generator
- Removed rspec file from rails generator

## [1.0.8] - 2019-09-16
### Changed
- Changed create propagation to check errors instead of persistence

## [1.0.7] - 2019-09-12
### Added
- Add propagation mixin

## [1.0.6] - 2019-09-07
### Added
- Raise error when class `call` if class doesn't respond_to `execute`

## [1.0.5] - 2019-09-05
### Added
- Add `merge_exception!` method to errors module

## [1.0.4] - 2019-09-02
### Added
- Add `merge_errors!` method to errors module

## [1.0.3] - 2019-09-02
### Added
- Add rails generators

## [1.0.2] - 2019-08-12
### Changed
- Renamed command method to execute
- Renamed run method to execute

## [1.0.1] - 2019-08-07
### Changed
- Pass args to command in call for Simple based commands

## [1.0.0] - 2019-08-07
### Added
- Initial project version
