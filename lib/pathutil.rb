# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "forwardable/extended"
require "find"

#

class Pathutil
  extend Forwardable::Extended
  attr_writer :encoding

  # --------------------------------------------------------------------------

  def initialize(path)
    @path = path.respond_to?(:to_path) ? path.to_path : path.to_s
  end

  # --------------------------------------------------------------------------
  # Search backwards for a file (like Rakefile, _config.yml, opts.yml).
  # @note It will return all results that it finds across all ascending paths.
  # @param backwards how far do you wish to search backwards in that path?
  # @param file the file you are searching for.
  #
  # @example
  #   Pathutil.new("~/").expand_path.search_backwards(".bashrc") => [
  #     #<Pathutil:/home/user/.bashrc>
  #   ]
  # --------------------------------------------------------------------------

  def search_backwards(file, backwards: Float::INFINITY)
    ary = []

    ascend.with_index(1).each do |path, index|
      if index > backwards
        break

      else
        Dir.chdir path do
          if block_given?
            file = self.class.new(file)
            if yield(file)
              ary.push(
                self
              )
            end

          elsif File.exist?(file)
            ary.push(self.class.new(
              path.join(file)
            ))
          end
        end
      end
    end

    ary
  end

  # --------------------------------------------------------------------------

  def read_yaml(throw_missing: false, **kwd)
    self.class.parse_yaml(
      read, **kwd
    )

  rescue Errno::ENOENT
    throw_missing ? raise : (
      return {}
    )
  end

  # --------------------------------------------------------------------------

  def read_json(throw_missing: false)
    JSON.parse(
      read
    )

  rescue Errno::ENOENT
    throw_missing ? raise : (
      return {}
    )
  end

  # --------------------------------------------------------------------------
  # Splits the path into all parts so that you can do step by step comparisons
  # @note The blank part is intentionally left there so that you can rejoin.
  #
  # @example
  #   Pathutil.new("/my/path").split_path # => [
  #     "", "my", "path"
  #   ]
  # --------------------------------------------------------------------------

  def split_path
    @path.split(
      File::SEPARATOR
    )
  end

  # --------------------------------------------------------------------------
  # @see `String#==` for more details.
  # A stricter version of `==` that also makes sure the object matches.
  # @param [Pathutil] other the comparee.
  # @return true, false
  # --------------------------------------------------------------------------

  def ===(other)
    other.is_a?(self.class) && @path == other
  end

  # --------------------------------------------------------------------------
  # @example Pathutil.new("/hello") >= Pathutil.new("/") # => true
  # @example Pathutil.new("/hello") >= Pathutil.new("/hello") # => true
  # Checks to see if a path falls within a path and deeper or is the other.
  # @param path the path that should be above the object.
  # @return true, false
  # --------------------------------------------------------------------------

  def >=(other)
    mine, other = expanded_paths(other)
    return true if other == mine
    mine.in_path?(other)
  end

  # --------------------------------------------------------------------------
  # @example Pathutil.new("/hello/world") > Pathutil.new("/hello") # => true
  # Strictly checks to see if a path is deeper but within the path of the other.
  # @param path the path that should be above the object.
  # @return true, false
  # --------------------------------------------------------------------------

  def >(other)
    mine, other = expanded_paths(other)
    return false if other == mine
    mine.in_path?(other)
  end

  # --------------------------------------------------------------------------
  # @example Pathutil.new("/") < Pathutil.new("/hello") # => true
  # Strictly check to see if a path is behind other path but within it.
  # @param path the path that should be below the object.
  # @return true, false
  # --------------------------------------------------------------------------

  def <(other)
    mine, other = expanded_paths(other)
    return false if other == mine
    other.in_path?(mine)
  end

  # --------------------------------------------------------------------------
  # Check to see if a path is behind the other path butt within it.
  # @example Pathutil.new("/hello") < Pathutil.new("/hello") # => true
  # @example Pathutil.new("/") < Pathutil.new("/hello") # => true
  # @param path the path that should be below the object.
  # @return true, false
  # --------------------------------------------------------------------------

  def <=(other)
    mine, other = expanded_paths(other)
    return true if other == mine
    other.in_path?(mine)
  end

  # --------------------------------------------------------------------------
  # @note "./" is considered relative.
  # Check to see if the path is absolute, as in: starts with "/"
  # @return true, false
  # --------------------------------------------------------------------------

  def absolute?
    @path.start_with?("/")
  end

  # --------------------------------------------------------------------------
  # Break apart the path and yield each with the previous parts.
  # @return Enumerator if no block is given.
  #
  # @example
  #   Pathutil.new("/hello/world").ascend.to_a # => [
  #     "/", "/hello", "/hello/world"
  #   ]
  #
  # @example
  #   Pathutil.new("/hello/world").ascend do |path|
  #     $stdout.puts path
  #   end
  #
  #   /
  #   /hello
  #   /hello/world
  # --------------------------------------------------------------------------

  def ascend
    unless block_given?
      return to_enum(
        __method__
      )
    end

    yield(
      path = self
    )

    while (new_path = path.dirname)
      if path == new_path || new_path == "."
        break
      else
        path = new_path
        yield  new_path
      end
    end

    nil
  end

  # --------------------------------------------------------------------------
  # Break apart the path in reverse order and descend into the path.
  # @return Enumerator if no block is given.
  #
  # @example
  #   Pathutil.new("/hello/world").descend.to_a # => [
  #     "/hello/world", "/hello", "/"
  #   ]
  #
  # @example
  #   Pathutil.new("/hello/world").descend do |path|
  #     $stdout.puts path
  #   end
  #
  #   /hello/world
  #   /hello
  #   /
  # --------------------------------------------------------------------------

  def descend
    unless block_given?
      return to_enum(
        __method__
      )
    end

    ascend.to_a.reverse_each do |val|
      yield val
    end

    nil
  end

  # --------------------------------------------------------------------------
  # Wraps `readlines` and allows you to yield on the result.
  #
  # @example
  #   Pathutil.new("/hello/world").each_line do |line|
  #     $stdout.puts line
  #   end
  #
  #   Hello
  #   World
  # --------------------------------------------------------------------------

  def each_line
    return to_enum(__method__) unless block_given?
    readlines.each do |line|
      yield line
    end

    nil
  end

  # --------------------------------------------------------------------------
  # @see `File#fnmatch` for more information.
  # Unlike traditional `fnmatch`, with this one `Regexp` is allowed.
  # @param [String, Regexp] matcher the matcher used, can be a `Regexp`
  # @example Pathutil.new("/hello").fnmatch?("/hello") # => true
  # @example Pathutil.new("/hello").fnmatch?(/h/) # => true
  # @return true, false
  # --------------------------------------------------------------------------

  def fnmatch?(matcher)
    matcher.is_a?(Regexp) ? !!(self =~ matcher) : \
      File.fnmatch(self, matcher)
  end

  # --------------------------------------------------------------------------
  # Allows you to quickly determine if the file is the root folder.
  # @return true, false
  # --------------------------------------------------------------------------

  def root?
    self == File::SEPARATOR
  end

  # --------------------------------------------------------------------------
  # @param [Pathutil, String] path the reference.
  # Allows you to check if the current path is in the path you want.
  # @return true, false
  # --------------------------------------------------------------------------

  def in_path?(path)
    path = self.class.new(path).expand_path.split_path
    mine = (symlink?? expand_path.realpath : expand_path).split_path
    path.each_with_index { |part, index| return false if mine[index] != part }
    true
  end

  # --------------------------------------------------------------------------

  def inspect
    "#<#{self.class}:#{@path}>"
  end

  # --------------------------------------------------------------------------
  # Grab all of the children from the current directory, including hidden.
  # @return Array<Pathutils>
  # --------------------------------------------------------------------------

  def children
    ary = []

    Dir.foreach(@path) do |path|
      if path == "." || path == ".."
        next
      else
        path = self.class.new(File.join(@path, path))
        yield path if block_given?
        ary.push(
          path
        )
      end
    end

    ary
  end

  # --------------------------------------------------------------------------
  # @see `File::Constants` for a list of flags.
  # Allows you to glob however you wish to glob in the current `Pathutils`
  # @param [String] flags the flags you want to ship to the glob.
  # @param [String] pattern the pattern A.K.A: "**/*"
  # @return Enumerator unless a  block is given.
  # --------------------------------------------------------------------------

  def glob(pattern, flags = 0)
    unless block_given?
      return to_enum(
        __method__, pattern, flags
      )
    end

    chdir do
      Dir.glob(pattern, flags).each do |file|
        yield self.class.new(
          File.join(@path, file)
        )
      end
    end

    nil
  end

  # --------------------------------------------------------------------------
  # @note you do not need to ship a block at all.
  # Move to the current directory temporarily (or for good) and do work son.
  # @return 0, 1 if no block given
  # --------------------------------------------------------------------------

  def chdir
    if !block_given?
      Dir.chdir(
        @path
      )

    else
      Dir.chdir @path do
        yield
      end
    end
  end

  # --------------------------------------------------------------------------
  # @return Enumerator if no block is given.
  # Find all files without care and yield the given block.
  # @see Find.find
  # --------------------------------------------------------------------------

  def find
    return to_enum(__method__) unless block_given?
    Find.find @path do |val|
      yield self.class.new(val)
    end
  end

  # --------------------------------------------------------------------------
  # Splits the path returning each part (filename) back to you.
  # @return Enumerator if no block is given.
  # --------------------------------------------------------------------------

  def each_filename
    return to_enum(__method__) unless block_given?
    @path.split(File::SEPARATOR).delete_if(&:empty?).each do |file|
      yield file
    end
  end

  # --------------------------------------------------------------------------

  def parent
    return self if @path == "/"
    self.class.new(absolute?? File.dirname(@path) : File.join(
      @path, ".."
    ))
  end

  # --------------------------------------------------------------------------
  # Split the file into its dirname and basename, so you can do stuff.
  # @return File.dirname, File.basename
  # --------------------------------------------------------------------------

  def split
    File.split(@path).collect! do |path|
      self.class.new(path)
    end
  end

  # --------------------------------------------------------------------------
  # Replace a files extension with your given extension.
  # --------------------------------------------------------------------------

  def sub_ext(ext)
    self.class.new(
      "#{@path.gsub(/\..+$/, "")}#{ext}"
    )
  end

  # --------------------------------------------------------------------------
  # A less complex version of `relative_path_from` that simply uses a
  # `Regexp` and returns the full path if it cannot be relatively determined.
  # @return Pathutils the relative path if it can be determined or is relative.
  # @return Pathutils the full path if relative path cannot be determined
  # --------------------------------------------------------------------------

  def relative_path_from(from)
    from = self.class.new(from).expand_path.gsub(%r!/$!, "")
    self.class.new(expand_path.gsub(%r!^#{from.regexp_escape}/!, ""))
  end

  # --------------------------------------------------------------------------
  # Expands the path and left joins the root to the path.
  # @param [String, Pathutil] root the root you wish to enforce on it.
  # @return Pathutil the enforced path with given root.
  # --------------------------------------------------------------------------

  def enforce_root(root)
    curr, root = expanded_paths(root)
    if curr.in_path?(root)
      return curr

    else
      File.join(
        root, curr
      )
    end
  end

  # --------------------------------------------------------------------------
  # Copy a directory, allowing symlinks if the link falls inside of the root.
  # --------------------------------------------------------------------------

  def safe_copy(to, root: nil)
    raise ArgumentError, "must give a root" unless root
    to = self.class.new(to)

    root = self.class.new(root)
    return safe_copy_directory(to, :root => root) if directory?
    safe_copy_file(to, :root => root)
  end

  # --------------------------------------------------------------------------
  # @see `self.class.normalize` as this is an alias.
  # --------------------------------------------------------------------------

  def normalize
    return @normalize ||= begin
      self.class.normalize
    end
  end

  # --------------------------------------------------------------------------
  # @see `self.class.encoding` as this is an alias.
  # --------------------------------------------------------------------------

  def encoding
    return @encoding ||= begin
      self.class.encoding
    end
  end

  # --------------------------------------------------------------------------
  # Read took two steroid shots: it can normalize your string, and encode.
  # --------------------------------------------------------------------------

  def read(*args, **kwd)
    kwd[:encoding] ||= encoding

    if normalize[:read]
      File.read(self, *args, kwd).encode({
        :universal_newline => true
      })

    else
      File.read(
        self, *args, kwd
      )
    end
  end

  # --------------------------------------------------------------------------
  # Binread took two steroid shots: it can normalize your string, and encode.
  # --------------------------------------------------------------------------

  def binread(*args, **kwd)
    kwd[:encoding] ||= encoding

    if normalize[:read]
      File.binread(self, *args, kwd).encode({
        :universal_newline => true
      })

    else
      File.read(
        self, *args, kwd
      )
    end
  end

  # --------------------------------------------------------------------------
  # Readlines took two steroid shots: it can normalize your string, and encode.
  # --------------------------------------------------------------------------

  def readlines(*args, **kwd)
    kwd[:encoding] ||= encoding

    if normalize[:read]
      File.readlines(self, *args, kwd).encode({
        :universal_newline => true
      })

    else
      File.readlines(
        self, *args, kwd
      )
    end
  end

  # --------------------------------------------------------------------------
  # Write took two steroid shots: it can normalize your string, and encode.
  # --------------------------------------------------------------------------

  def write(data, *args, **kwd)
    kwd[:encoding] ||= encoding

    if normalize[:write]
      File.write(self, data.encode(
        :crlf_newline => true
      ), *args, kwd)

    else
      File.write(
        self, data, *args, kwd
      )
    end
  end

  # --------------------------------------------------------------------------
  # Binwrite took two steroid shots: it can normalize your string, and encode.
  # --------------------------------------------------------------------------

  def binwrite(data, *args, **kwd)
    kwd[:encoding] ||= encoding

    if normalize[:write]
      File.binwrite(self, data.encode(
        :crlf_newline => true
      ), *args, kwd)

    else
      File.binwrite(
        self, data, *args, kwd
      )
    end
  end

  # --------------------------------------------------------------------------
  # @api returns the current objects expanded path and their expanded path.
  # --------------------------------------------------------------------------

  private
  def expanded_paths(path)
    return expand_path, self.class.new(path).expand_path
  end

  # --------------------------------------------------------------------------

  private
  def safe_copy_file(to, root: nil)
    raise Errno::EPERM, "#{self} not in #{root}" unless in_path?(root)
    FileUtils.cp(self, to, {
      :preserve => true
    })
  end

  # --------------------------------------------------------------------------

  private
  def safe_copy_directory(to, root: nil)
    if !in_path?(root)
      raise Errno::EPERM, "#{self} not in #{
        root
      }"

    else
      to.mkdir_p unless to.exist?
      children do |file|
        if !file.in_path?(root)
          raise Errno::EPERM, "#{file} not in #{
            root
          }"

        elsif file.file?
          FileUtils.cp(file, to, {
            :preserve => true
          })

        else
          path = file.realpath
          path.safe_copy(to.join(file.basename), {
            :root => root
          })
        end
      end
    end
  end

  # --------------------------------------------------------------------------

  class << self
    attr_writer :encoding

    # ------------------------------------------------------------------------
    # Wraps around YAML and SafeYAML to provide alternatives to Rubies.
    # @note We default aliases to yes so we can detect if you explicit true.
    # ------------------------------------------------------------------------

    def parse_yaml(data, safe: true, whitelist_classes: [], whitelist_symbols: [], aliases: :yes)
      require "yaml"

      unless safe
        return YAML.load(
          data
        )
      end

      if !YAML.respond_to?(:safe_load)
        setup_safe_yaml whitelist_classes, aliases
        SafeYAML.load(
          data
        )

      else
        YAML.safe_load(
          data,
          whitelist_classes,
          whitelist_symbols,
          aliases
        )
      end
    end

    # ------------------------------------------------------------------------
    # Aliases the default system encoding to us so that we can do most read
    # and write operations with that encoding, instead of being crazy.
    # @note you are encouraged to override this if you need to.
    # ------------------------------------------------------------------------

    def encoding
      return @encoding ||= begin
        Encoding.default_external
      end
    end

    # ------------------------------------------------------------------------
    # Normalize CRLF -> LF on Windows reads, to ease  your troubles.
    # Normalize LF -> CLRF on Windows write, to ease their troubles.
    # ------------------------------------------------------------------------

    def normalize
      return @normalize ||= {
        :read  => Gem.win_platform?,
        :write => Gem.win_platform?
      }
    end

    # ------------------------------------------------------------------------

    def make_tmpname(prefix = "", suffix = nil)
      prefix = prefix.gsub(/\-\Z/, "") + "-" unless prefix.empty?

      File.join(
        Dir::Tmpname.tmpdir,
        Dir::Tmpname.make_tmpname(
          prefix, suffix
        )
      )
    end

    # ------------------------------------------------------------------------

    private
    def setup_safe_yaml(whitelist_classes, aliases)
      warn "WARN: SafeYAML will be removed when Ruby 2.0 goes EOL."
      warn "WARN: Disabling aliases is not supported with SafeYAML" if aliases && aliases != :yes
      require "safe_yaml/load"

      SafeYAML.restore_defaults!
      whitelist_classes.map(&SafeYAML.method(
        :whitelist_class!
      ))
    end
  end

  # --------------------------------------------------------------------------

  rb_delegate :sub,     :to => :@path, :wrap => true
  rb_delegate :chomp,   :to => :@path, :wrap => true
  rb_delegate :gsub,    :to => :@path, :wrap => true
  rb_delegate :=~,      :to => :@path
  rb_delegate :==,      :to => :@path
  rb_delegate :to_s,    :to => :@path
  rb_delegate :freeze,  :to => :@path
  rb_delegate :frozen?, :to => :@path
  rb_delegate :to_str,  :to => :@path
  rb_delegate :"!~",    :to => :@path
  rb_delegate :<=>,     :to => :@path

  # --------------------------------------------------------------------------

  rb_delegate :basename,     :to => :File, :args => :@path, :wrap => true
  rb_delegate :dirname,      :to => :File, :args => :@path, :wrap => true
  rb_delegate :readlink,     :to => :File, :args => :@path, :wrap => true
  rb_delegate :expand_path,  :to => :File, :args => :@path, :wrap => true
  rb_delegate :realdirpath,  :to => :File, :args => :@path, :wrap => true
  rb_delegate :realpath,     :to => :File, :args => :@path, :wrap => true
  rb_delegate :rename,       :to => :File, :args => :@path, :wrap => true
  rb_delegate :join,         :to => :File, :args => :@path, :wrap => true
  rb_delegate :size,         :to => :File, :args => :@path
  rb_delegate :link,         :to => :File, :args => :@path
  rb_delegate :atime,        :to => :File, :args => :@path
  rb_delegate :chown,        :to => :File, :args => :@path
  rb_delegate :ctime,        :to => :File, :args => :@path
  rb_delegate :lstat,        :to => :File, :args => :@path
  rb_delegate :utime,        :to => :File, :args => :@path
  rb_delegate :lchmod,       :to => :File, :args => :@path
  rb_delegate :sysopen,      :to => :File, :args => :@path
  rb_delegate :birthtime,    :to => :File, :args => :@path
  rb_delegate :mountpoint?,  :to => :File, :args => :@path
  rb_delegate :truncate,     :to => :File, :args => :@path
  rb_delegate :symlink,      :to => :File, :args => :@path
  rb_delegate :extname,      :to => :File, :args => :@path
  rb_delegate :lchown,       :to => :File, :args => :@path
  rb_delegate :zero?,        :to => :File, :args => :@path
  rb_delegate :ftype,        :to => :File, :args => :@path
  rb_delegate :chmod,        :to => :File, :args => :@path
  rb_delegate :mtime,        :to => :File, :args => :@path
  rb_delegate :open,         :to => :File, :args => :@path
  rb_delegate :stat,         :to => :File, :args => :@path

  # --------------------------------------------------------------------------

  rb_delegate :pipe?,            :to => :FileTest, :args => :@path
  rb_delegate :file?,            :to => :FileTest, :args => :@path
  rb_delegate :owned?,           :to => :FileTest, :args => :@path
  rb_delegate :setgid?,          :to => :FileTest, :args => :@path
  rb_delegate :socket?,          :to => :FileTest, :args => :@path
  rb_delegate :readable?,        :to => :FileTest, :args => :@path
  rb_delegate :blockdev?,        :to => :FileTest, :args => :@path
  rb_delegate :directory?,       :to => :FileTest, :args => :@path
  rb_delegate :readable_real?,   :to => :FileTest, :args => :@path
  rb_delegate :world_readable?,  :to => :FileTest, :args => :@path
  rb_delegate :executable_real?, :to => :FileTest, :args => :@path
  rb_delegate :world_writable?,  :to => :FileTest, :args => :@path
  rb_delegate :writable_real?,   :to => :FileTest, :args => :@path
  rb_delegate :executable?,      :to => :FileTest, :args => :@path
  rb_delegate :writable?,        :to => :FileTest, :args => :@path
  rb_delegate :grpowned?,        :to => :FileTest, :args => :@path
  rb_delegate :chardev?,         :to => :FileTest, :args => :@path
  rb_delegate :symlink?,         :to => :FileTest, :args => :@path
  rb_delegate :sticky?,          :to => :FileTest, :args => :@path
  rb_delegate :setuid?,          :to => :FileTest, :args => :@path
  rb_delegate :exist?,           :to => :FileTest, :args => :@path
  rb_delegate :size?,            :to => :FileTest, :args => :@path

  # --------------------------------------------------------------------------

  rb_delegate :rm_rf,   :to => :FileUtils, :args => :@path
  rb_delegate :rm_r,    :to => :FileUtils, :args => :@path
  rb_delegate :rm_f,    :to => :FileUtils, :args => :@path
  rb_delegate :rm,      :to => :FileUtils, :args => :@path
  rb_delegate :cp_r,    :to => :FileUtils, :args => :@path
  rb_delegate :touch,   :to => :FileUtils, :args => :@path
  rb_delegate :mkdir_p, :to => :FileUtils, :args => :@path
  rb_delegate :mkpath,  :to => :FileUtils, :args => :@path
  rb_delegate :cp,      :to => :FileUtils, :args => :@path

  # --------------------------------------------------------------------------

  rb_delegate :each_child, :to => :children
  rb_delegate :each_entry, :to => :children
  rb_delegate :to_a,       :to => :children

  # --------------------------------------------------------------------------

  rb_delegate :opendir, :to => :Dir, :alias_of => :open
  rb_delegate :relative?, :to => :self, :alias_of => :absolute?, :bool => :reverse
  rb_delegate :regexp_escape, :to => :Regexp, :args => :@path, :alias_of => :escape
  rb_delegate :to_regexp, :to => :Regexp, :args => :@path, :alias_of => :new
  rb_delegate :shellescape, :to => :Shellwords, :args => :@path
  rb_delegate :mkdir, :to => :Dir, :args => :@path

  # --------------------------------------------------------------------------
  # alias last basename, alias first dirname, alias ext extname
  # --------------------------------------------------------------------------

  alias + join
  alias delete rm
  alias rmtree rm_r
  alias to_path to_s
  alias last basename
  alias entries children
  alias make_symlink symlink
  alias fnmatch fnmatch?
  alias make_link link
  alias first dirname
  alias rmdir rm_r
  alias unlink rm
  alias / join
end
