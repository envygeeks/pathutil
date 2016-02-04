# Change Log

All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

## 0.3.0
#### Added/Changed
- Add `Pathutil.pwd`
- Add `Pathutil.getcwd`
- Split up YAML processing so it's encapsulated better.
- Start benchmarking YAML.
- Add `Pathutil.cwd`

## 0.2.0
#### Added/Changed
- Make descend slightly faster without a block.
- Start duping the object we receive after converting it.
- Move class methods lower in the defs.
- Add `Pathutil.make_tmpname`
- Cleanup the specs.

## 0.1.0
#### Added/Changed
- Make sure `Tempfile` is available for the specs.
- Add `search_backwards` method to find all files ascendingly.
- Remove `to_pathname` it serves no purpose.
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
