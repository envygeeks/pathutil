class Pathutil
  module Helpers
    extend self

    # Wraps around YAML and SafeYAML to provide alternatives to Rubies.
    # Note: We default aliases to yes so we can detect if you explicit true.
    def load_yaml(data, safe: true, whitelist_classes: [], whitelist_symbols: [], aliases: :yes)
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

    # Make a temporary name suitable for temporary files and directories.
    # root - where you would like to place the temp name when the path is given out.
    # suffix - the suffix of the file or folder (can be an extension.)
    # prefix - the prefix of the file or folder.
    def make_tmpname(prefix = "", suffix = nil, root = nil)
      prefix = tmpname_prefix(prefix)
      suffix = tmpname_suffix(suffix)

      root ||= Dir::Tmpname.tmpdir
      File.join(root, Dir::Tmpname.make_tmpname(
        prefix, suffix
      ))
    end

    private
    # Cleanup the temp name suffix, joining if necessary.
    # suffix - the suffix that needs to be cleaned up.
    def tmpname_suffix(suffix)
      suffix = suffix.join("-") if suffix.is_a?(Array)
      suffix = suffix.gsub(/\A\-/, "") unless !suffix || suffix.empty?
      suffix
    end

    private
    # rubocop:disable Style/ParallelAssignment
    # Cleanup the temp name prefix, joining if necessary.
    # prefix - the prefix that needs to be cleaned up.
    def tmpname_prefix(prefix)
      ext, prefix = prefix, "" if !prefix.is_a?(Array) && prefix.start_with?(".")
      ext = prefix.pop if prefix.is_a?(Array) && prefix[-1].start_with?(".")
      prefix = prefix.join("-") if prefix.is_a?(Array)

      unless prefix.empty?
        prefix = prefix.gsub(/\-\Z/, "") \
          + "-"
      end

      return [
        prefix, ext || ""
      ]
    end

    private
    # rubocop:enable Style/ParallelAssignment
    # Note: If you are on Ruby 2.2+ you should just use built-in `YAML(safe: true)`
    # Wrap around, cleanup, deprecate and use SafeYAML.
    def setup_safe_yaml(whitelist_classes, aliases)
      warn "WARN: SafeYAML does not support disabling  of aliases." if aliases && aliases != :yes
      warn "WARN: SafeYAML will be removed when Ruby 2.0 goes EOL."
      require "safe_yaml/load"

      SafeYAML.restore_defaults!
      whitelist_classes.map(&SafeYAML.method(
        :whitelist_class!
      ))
    end
  end
end
