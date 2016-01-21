# Change Log

All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

## [UNRELEASED]
#### Added/Changed
- Make sure `Tempfile` is available for the specs.
- Add `search_backwards` method to find all files ascendingly.
- Superficially drop support for 2.0.0.

## 0.2.0
#### Added/Changed
- Added `rm_f` so you can force delete non-recursively.
- Start running `#to_pathname` before `#to_s` on initialize.

## 0.1.0
#### Added
- Initial release.
- All Pathname methods available.
- Some extra methods.
