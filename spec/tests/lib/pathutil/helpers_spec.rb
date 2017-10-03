# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8

require "rspec/helper"
require "yaml"

describe Pathutil::Helpers do
  let :file do
    Pathutil.new(described_class.make_tmpname(
      "pathutil", "spec"
    ))
  end

  #

  after do
    file.rm_rf
  end

  #

  describe "#load_yaml" do
    it "should be able to parse YAML" do
      expect(described_class.load_yaml("hello: world")).to eq({
        "hello" => "world"
      })
    end

    #

    context "when safe" do
      it "should reject any special classes", :disable => :oldest_ruby do
        expect { described_class.load_yaml(":hello: :world") }.to raise_error(
          Psych::DisallowedClass
        )
      end

      #

      context "when using SafeYAML" do
        before do
          allow(YAML).to receive(:respond_to?).with(:safe_load).and_return(false)
          expect_any_instance_of(described_class).to receive(:warn).and_return(
            nil
          )
        end

        #

        context do
          it "should warn it's deprecated" do
            expect(described_class).to receive(:warn).and_return(
              nil
            )
          end

          #

          after do
            described_class.load_yaml(
              ":hello: :world"
            )
          end
        end

        #

        context "when trying to disable aliases" do
          it "should warn that you cannot disable them in SafeYAML" do
            expect(described_class).to receive(:warn).exactly(2).times.and_return(
              nil
            )
          end

          #

          after do
            described_class.load_yaml("hello: world", {
              :aliases => true
            })
          end
        end

        #

        it "should parse with SafeYAML" do
          expect(described_class.load_yaml(":hello: :world")).to eq({
            ":hello" => ":world"
          })
        end
      end
    end

    #

    context "when whitelisting classes" do
      it "should allow that class to be loaded" do
        expect(described_class.load_yaml(":hello: :world", :whitelist_classes => [Symbol])).to eq({
          :hello => :world
        })
      end
    end

    #

    context "when diallowing aliases" do
      it "should throw the parse" do
        yaml = "version: &version 1\nother_version: *version"
        expect { described_class.load_yaml(yaml, :aliases => false) }.to raise_error(
          Psych::BadAlias
        )
      end
    end

    #

    context do
      it "should allow aliases by default" do
        expect(described_class.load_yaml("version: &version 1\nother_version: *version")).to eq({
          "version" => 1, "other_version" => 1
        })
      end
    end

    #

    context do
      it "should parse YAML" do
        expect(described_class.load_yaml("hello: world\nworld: hello")).to eq({
          "hello" => "world",
          "world" => "hello"
        })
      end
    end
  end

  #

  describe ".make_tmpname" do
    context "when the user sends a root" do
      let :result do
        described_class.make_tmpname(
          "hello", "person", "/world"
        )
      end

      it "should use that folder" do
        expect(result).to start_with(
          "/world"
        )
      end
    end

    context "when the user uses an extension" do
      let :result do
        described_class.make_tmpname(
          ["hello", ".world"], "you"
        )
      end

      it "should put the extension on the end" do
        expect(result).to end_with(
          ".world"
        )
      end
    end

    let :result do
      described_class.make_tmpname(
        "hello", "world"
      )
    end

    #

    it "should be able to add a suffix" do
      expect(result).to end_with(
        "-world"
      )
    end

    #

    context "when a user sends no prefix or suffix" do
      it "should not add extra dashes" do
        expect { described_class.make_tmpname }.not_to(
          raise_error
        )
      end
    end

    #

    it "should be able to add a prefix" do
      expect(result).to match(
        %r!/hello-!
      )
    end
  end
end
