# Pathutil

`Pathutil` tries to be a faster pure `ruby` impelementation of `Pathname`.  It
arose out of a need to fix basic problems with `Pathname`, such as suscepetibility
to `Pathname.new("/tmp").join("/lol") => <Pathname:/lol>`, need for automatic encoding
and normalization (for stuff like Jekyll) and the ability to do other safe-style
operations in an encapsulated format, like copying files and folders with
symlinks but only if they originate from the given root.

## Current (All) Methods

`relative_path_from`, `touch`, `mkpath`, `rmtree`, `rm_r`, `sub_ext`, `directory?`, `exist?`, `opendir`, `readable?`, `readable_real?`, `world_readable?`, `writable?`, `writable_real?`, `world_writable?`, `executable?`, `executable_real?`, `file?`, `size?`, `owned?`, `grpowned?`, `pipe?`, `symlink?`, `socket?`, `blockdev?`, `chardev?`, `setuid?`, `setgid?`, `sticky?`, `stat`, `lstat`, `ftype`, `atime`, `mtime`, `ctime`, `birthtime`, `utime`, `chmod`, `chown`, `lchmod`, `lchown`, `link`, `symlink`, `readlink`, `truncate`, `rename`, `find`, `unlink`, `expand_path`, `normalize`, `realpath`, `<`, `basename`, `>`, `realdirpath`, `extname`, `dirname`, `cp_r`, `rm`, `zero?`, `make_link`, `cp`, `rm_rf`, `entries`, `/`, `+`, `make_symlink`, `first`, `to_path`, `each_entry`, `shellescape`, `to_regexp`, `chdir`, `mkdir`, `rmdir`, `glob`, `fnmatch?`, `<=`, `>=`, `fnmatch`, `split`, `read`, `write`, `sub`, `gsub`, `chomp`, `mkdir_p`, `open`, `readlines`, `delete`, `size`, `each_line`, `sysopen`, `encoding`, `binwrite`, `binread`, `to_str`, `to_a`, `split_path`, `to_pathname`, `read_yaml`, `read_json`, `in_path?`, `regexp_escape`, `enforce_root`, `parent`, `safe_copy`, `root?`, `absolute?`, `relative?`, `each_filename`, `descend`, `last`, `ascend`, `join`, `encoding=`, `mountpoint?`, `children`, `each_child`

### Diverging (or New/Extra) Methods

- `encoding`, `encoding=`: Set the read/write encoding.
- `!~`, `=~`: Regexp operations on the path, behaves normally.
- `>=`, `>`: Check if a file is in but ahead of a path: `Pathutil.new("/tmp/hello") > "/tmp" # => true`
- `in_path?`: Check if a file is within a given path: `Pathutil.new("/tmp/hello").in_path?("/tmp") # => true`
- `<=`, `<`: Check if a file is in but below a path: `Pathutil.new("/tmp") < "/tmp/hello" # => true`
- `read_yaml`: a wrapper around `Yaml.safe_load` and `SafeYAML` to make reading `YAML` easy.
- `children`: behaves like Pathname, except it accepts a block to work on the path.
- `safe_copy`: Copy files, disallowing symlinks unless `in_path?`
- `enforce_root`: Force a root if not already in that root.
- `normalize`: CRLF => LF (read), LF => CRLF (write).
- `read_yaml`: Read YAML with or without safe.

`touch`, `rm_r`, `link`, `symlink`, `cp_r`, `rm`, `cp`, `rm_rf`, `first` (alias of `dirname`), `shellescape`, `to_regexp`, `chdir`, `glob` (does `chdir` first), `gsub` (works on `@path`), `chomp` (works on `@path`), `mkdir_p`, `to_str` (alias of `to_s`), `to_a` (alias of `children`), `regexp_escape`, `last` (alias of `basename`), `to_pathname`, `split_path`, `read_json`
