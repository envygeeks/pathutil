# Frozen-string-literal: true
# Copyright: 2015 - 2017 Jordon Bedwell - MIT License
# Encoding: utf-8

class Pathutil
  module Helpers
    extend self

    # --

    def allowed
      return @allowed ||= begin
        {
          :yaml => {
            :classes => [],
            :symbols => []
          }
        }
      end
    end

    # --
    # Wraps around YAMLto provide alternatives to Rubies.
    # @note We default aliases to yes so we can detect if you explicit true.
    # @return Hash
    # --
    def load_yaml(data, safe: true, whitelist_classes: allowed[:yaml][:classes], \
        whitelist_symbols: allowed[:yaml][:symbols], aliases: :yes)

      require "yaml"
      unless safe
        return YAML.load(
          data
        )
      end

      YAML.safe_load(
        data,
        permitted_classes: whitelist_classes,
        permitted_symbols: whitelist_symbols,
        aliases: aliases
      )
    end

    # --
    # Make a temporary name suitable for temporary files and directories.
    # @return String
    # --
    def make_tmpname(prefix = "", suffix = nil, root = nil)
      prefix = tmpname_prefix(prefix)
      suffix = tmpname_suffix(suffix)

      root ||= Dir::Tmpname.tmpdir
      File.join(root, __make_tmpname(
        prefix, suffix
      ))
    end

    # --
    private
    def __make_tmpname((prefix, suffix), number)
      prefix &&= String.try_convert(prefix) || tmpname_agerr(:prefix, prefix)
      suffix &&= String.try_convert(suffix) || tmpname_agerr(:suffix, suffix)

      time = Time.now.strftime("%Y%m%d")
      path = "#{prefix}#{time}-#{$$}-#{rand(0x100000000).to_s(36)}".dup
      path << "-#{number}" if number
      path << suffix if suffix
      path
    end

    private
    def tmpname_agerr(type, val)
      raise ArgumentError, "unexpected #{type}: #{val.inspect}"
    end

    # --
    private
    def tmpname_suffix(suffix)
      suffix = suffix.join("-") if suffix.is_a?(Array)
      suffix = suffix.gsub(/\A\-/, "") unless !suffix || suffix.empty?
      suffix
    end

    # --
    # Cleanup the temp name prefix, joining if necessary.
    # rubocop:disable Style/ParallelAssignment
    # --
    private
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
  end
end
