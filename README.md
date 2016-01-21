# Pathutil

[![Build Status](https://travis-ci.org/envygeeks/pathutil.svg?branch=master)][travis]
[![Test Coverage](https://codeclimate.com/github/envygeeks/pathutil/badges/coverage.svg)][coverage]
[![Code Climate](https://codeclimate.com/github/envygeeks/pathutil/badges/gpa.svg)][codeclimate]
[![Dependency Status](https://gemnasium.com/envygeeks/pathutil.svg)][gemnasium]

[gemnasium]: https://gemnasium.com/envygeeks/pathutil
[codeclimate]: https://codeclimate.com/github/envygeeks/pathutil
[coverage]: https://codeclimate.com/github/envygeeks/pathutil/coverage
[travis]: https://travis-ci.org/envygeeks/pathutil

Pathutil tries to be a faster pure Ruby impelementation of Pathname.  It
arose out of a need to fix basic problems with Pathname, such as suscepetibility
to join overrides, need for automatic encoding, and normalization (for stuff
like Jekyll) and the ability to do other safe-style operations in an
encapsulated format, like copying files and folders with symlinks
but only if they originate from the given root.

### Diverging (or New/Extra) Methods

- `encoding`, `encoding=` - Set the read/write encoding.
- `normalize` - `crlf` => `lf` (read), `lf` => `crlf` (write).
- `!~`, `=~` - Regexp operations on the path, behaves normally.
- `search_backwards` - Allows you to search backwards for a file or folder.
- `>=`, `>` - Check if a file is in but ahead of a path: `Pathutil.new("/tmp/hello") > "/tmp" # => true`
- `in_path?` - Check if a file is within a given path: `Pathutil.new("/tmp/hello").in_path?("/tmp") # => true`
- `<=`, `<` - Check if a file is in but below a path: `Pathutil.new("/tmp") < "/tmp/hello" # => true`
- `read_yaml` - a wrapper around `Yaml.safe_load` and `SafeYAML` to make reading `YAML` easy.
- `children` - behaves like Pathname, except it accepts a block to work on the path.
- `safe_copy` - Copy files, disallowing symlinks unless `in_path?`
- `enforce_root` - Force a root if not already in that root.
- `read_yaml` - Read YAML with or without safe.
- `unlink` - Behaves like File.

`touch`, `rm_r`, `link`, `symlink`, `cp_r`, `rm`, `cp`, `rm_rf`, `first` (alias of `dirname`), `shellescape`, `to_regexp`, `chdir`, `glob` (does `chdir` first), `gsub` (works on `@path`), `chomp` (works on `@path`), `mkdir_p`, `to_str` (alias of `to_s`), `to_a` (alias of `children`), `regexp_escape`, `last` (alias of `basename`), `to_pathname`, `split_path`, `read_json`, `rm_f`

## Current (All) Methods

Pathutil has and responds to all methods that Pathname provides and forwards
them where they need to go with wrappers if necessary and with our `@path` as
the first argumement on our behalf.  It is a true encapsulator with a few
extra helpers to make your life easy.

`relative_path_from`, `touch`, `mkpath`, `rmtree`, `rm_r`, `sub_ext`, `directory?`, `exist?`, `opendir`, `readable?`, `readable_real?`, `world_readable?`, `writable?`, `writable_real?`, `world_writable?`, `executable?`, `executable_real?`, `file?`, `size?`, `owned?`, `grpowned?`, `pipe?`, `symlink?`, `socket?`, `blockdev?`, `chardev?`, `setuid?`, `setgid?`, `sticky?`, `stat`, `lstat`, `ftype`, `atime`, `mtime`, `ctime`, `birthtime`, `utime`, `chmod`, `chown`, `lchmod`, `lchown`, `link`, `symlink`, `readlink`, `truncate`, `rename`, `find`, `unlink`, `expand_path`, `normalize`, `realpath`, `<`, `basename`, `>`, `realdirpath`, `extname`, `dirname`, `cp_r`, `rm`, `zero?`, `make_link`, `cp`, `rm_rf`, `entries`, `/`, `+`, `make_symlink`, `first`, `to_path`, `each_entry`, `shellescape`, `to_regexp`, `chdir`, `mkdir`, `rmdir`, `glob`, `fnmatch?`, `<=`, `>=`, `fnmatch`, `split`, `read`, `write`, `sub`, `gsub`, `chomp`, `mkdir_p`, `open`, `readlines`, `delete`, `size`, `each_line`, `sysopen`, `encoding`, `binwrite`, `binread`, `to_str`, `to_a`, `split_path`, `to_pathname`, `read_yaml`, `read_json`, `in_path?`, `regexp_escape`, `enforce_root`, `parent`, `safe_copy`, `root?`, `absolute?`, `relative?`, `each_filename`, `descend`, `last`, `ascend`, `join`, `encoding=`, `mountpoint?`, `children`, `each_child`, `rm_f`
