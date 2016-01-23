class Pathutil
  module Helpers
    extend self

    # ------------------------------------------------------------------------
    # Wraps around YAML and SafeYAML to provide alternatives to Rubies.
    # @note We default aliases to yes so we can detect if you explicit true.
    # ------------------------------------------------------------------------

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
    # rubocop:disable Metrics/LineLength
    # ------------------------------------------------------------------------

    private
    def setup_safe_yaml(whitelist_classes, aliases)
      warn "#{self.class.name}:WARN: SafeYAML does not support disabling  of aliases." if aliases && aliases != :yes
      warn "#{self.class.name}:WARN: SafeYAML will be removed when Ruby 2.0 goes EOL."
      require "safe_yaml/load"

      SafeYAML.restore_defaults!
      whitelist_classes.map(&SafeYAML.method(
        :whitelist_class!
      ))
    end
  end
end
