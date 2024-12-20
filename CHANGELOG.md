# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.3.3] - 2024-11-25
### Changed
- Skip freezing in test environments so it doesnt interfere with stubbing

## [3.3.2] - 2024-11-08
### Changed
- Fixed issue where commands didnt delegate to private methods

## [3.3.1] - 2024-11-06
### Removed
- Remove `to_hash` method

## [3.3.0] - 2024-11-01
### Changed
- Prefixed util method with `cmd_`
- Improve monotonic clock handling
- Improve order of hook calls

## [3.2.1] - 2024-10-29
### Changed
- Allow if and unless evaluations to happen at the same time

## [3.2.0] - 2024-10-29
### Changed
- Move callbacks to hooks instead of try methods

## [3.1.5] - 2024-10-28
### Changed
- Renamed private `delegate` method to `delegates` to prevent rails clash

## [3.1.4] - 2024-10-27
### Added
- Add exception data to results hash
### Changed
- Relocated some results methods to a runtimes internal module
- Assign correct fault even when child command is hard called
- Renamed `fault_exception` to `command_exception`

## [3.1.3] - 2024-10-26
### Added
- Added passing `original_exception` to fault `!` calls
### Changed
- Move monotonic clock to util
- Changed `metadata` to a keyword arg on fault `!` calls
### Removed
- Removed unnecessary `Lite::Command::` prefixes
- Removed double if/unless eval for required validations

## [3.1.2] - 2024-10-26
### Changed
- Make state set methods private
- Add returns for invalid state and status transitions

## [3.1.1] - 2024-10-25
### Changed
- Add option to raise original or fault exception

## [3.1.0] - 2024-10-25
### Added
- Added `raise!` method to reraise soft call errors
### Changed
- Fixed leakage of configuration option changes in spec

## [3.0.1] - 2024-10-25
### Changed
- Changed equality check for better matching

## [3.0.0] - 2024-10-15
### Added
- Added `bad?` status method check
- Configuration class to handle dynamic error creation
- Added `on_before_validation` callback hook
- Added validation support
- Added new `required` and `optional` attribute methods
### Changed
- Improved values of `caused_by` and `thrown_by`
- Use try util instead of hook
### Removed
- Removed attributes method

## [2.1.3] - 2024-10-08
### Changed
- Move super in inheritance

## [2.1.2] - 2024-10-08
### Added
- Allow `filled` to pass `{ empty: false }` to check if value is empty

## [2.1.1] - 2024-10-06
### Added
- Added on_status hook to `execute!`
### Changed
- Reuse same attribute instance

## [2.1.0] - 2024-10-05
### Added
- Added passing metadata to faults
- Added `on_success` callback
- Added `on_pending`, `on_executing`, `on_complete`, and `on_interrupted` callbacks
- Added attributes and attribute validations
- Added steps and sequences
- Added fault streamer
### Changed
- Check error descendency instead of type
- Rename internal modules
- Make execute(!) methods private
### Removed
- Remove predefined callback methods
- Remove non-bang fault methods

## [2.0.3] - 2024-09-30
### Changed
- Simplify error building
- Reduced recalling error since we can just throw it once
- Rename `fault_name` to `type`

## [2.0.2] - 2024-09-29
### Added
- faultable module
### Changed
- Simplified status variable check
- Simplified context merge
- Fixed invalid looking at wrong variable
- Renamed `fault` and `thrower` to `caused_by` and `thrown_by` respectively
- Removed unused `additional_result_data` method
### Removed
- Removed context init

## [2.0.1] - 2024-09-27
### Removed
- Activemodel dependency

## [2.0.0] - 2024-09-27
### Changed
- Rewrite app to use interactor pattern

## [1.5.0] - 2022-04-19
### Changed
- Update docs
- Rename internal variables for more clarity
- Improved spec checkers

## [1.4.1] - 2021-09-04
### Changed
- Fixed nil issue with `assign_and_return!`

## [1.4.0] - 2021-09-04
### Added
- Added `assign_and_return!` to propagation extension

## [1.3.2] - 2021-07-21
### Changed
- Improved setup

## [1.3.1] - 2021-07-21
### Changed
- Improved Railtie support

## [1.3.0] - 2021-07-19
### Added
- Added Ruby 3.0 support

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
