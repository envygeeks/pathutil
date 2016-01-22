# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
require "tempfile"

describe Pathutil do
  (Pathname.instance_methods - Object.instance_methods).each do |method|
    unless method == :cleanpath
      specify { expect(described_class).to \
        have_method method }
    end
  end

  #

  let :file do
    described_class.new(
      Tempfile.new("spec").to_path
    )
  end

  #

  before do
    file.write(
      "#{alt.basename}\n#{subject.basename}"
    )
  end

  #

  after do
    file.rm_rf
  end

  #

  let :alt do
    described_class.new(
      "/hello"
    )
  end

  #

  subject do
    described_class.new(
      "/tmp"
    )
  end

  #

  describe "#initialize" do
    context "when given a File or Pathname, or otherwise" do
      before do
        file.touch
      end

      it "should convert it with #to_path" do
        expect(described_class.new(File.open(file)).instance_variable_get(:@path)).to eq(
          file.to_s
        )
      end
    end
  end

  #

  describe "#search_backwards" do
    let :path do
      file.rm_rf
      file.join(
        "hello/world/hello/hello"
      )
    end

    #

    before do
      path.mkdir_p
    end

    #

    it "should return all results it finds" do
      expect(path.search_backwards("hello").size).to eq(
        3
      )
    end

    #

    context "backwards: n" do
      it "should only step back that many times" do
        expect { |b| path.search_backwards("hello", :backwards => 2, &b) }.to(
          yield_control.twice
        )
      end
    end
  end

  #

  describe "#read_yaml" do
    before do
      file.rm_rf
    end

    #

    context "when the file doesn't exist" do
      context "and the user doesn't set throw_missing" do
        specify do
          expect(file.read_yaml).to eq({
            #
          })
        end
      end

      #

      context "and the user sets throw_missing" do
        specify do
          expect { file.read_yaml(throw_missing: true) }.to raise_error(
            Errno::ENOENT
          )
        end
      end
    end

    #

    context "when safe" do
      before do
        file.write(
          ":hello: :world"
        )
      end

      it "should reject any special classes", :disable => :oldest_ruby do
        expect { file.read_yaml }.to raise_error(
          Psych::DisallowedClass
        )
      end

      context "when using safe_yaml" do
        before do
          allow(YAML).to receive(:respond_to?).with(:safe_load).and_return(false)
          allow(file).to receive(:warn).and_return(
            nil
          )
        end

        context do
          specify do
            expect(file).to receive(:warn) do
              nil
            end
          end

          after do
            file.read_yaml
          end
        end

        specify do
          expect(file.read_yaml).to eq({
            ":hello"=>":world"
          })
        end
      end
    end

    #

    context "whitelisting classes" do
      before do
        file.write(
          ":hello: :world"
        )
      end

      #

      specify do
        expect(file.read_yaml(:whitelist_classes => [Symbol])).to eq({
          :hello => :world
        })
      end
    end

    #

    context "diallowing aliases" do
      before do
        file.write(
          "version: &version 1\nother_version: *version"
        )
      end

      #

      specify do
        expect { file.read_yaml(:aliases => false) }.to raise_error(
          Psych::BadAlias
        )
      end
    end

    #

    context do
      before do
        file.write(
          "version: &version 1\nother_version: *version"
        )
      end

      #

      it "should allow aliases by default" do
        expect(file.read_yaml).to eq({
          "version" => 1, "other_version" => 1
        })
      end
    end

    #

    context do
      before do
        file.write(
          "hello: world\nworld: hello"
        )
      end

      #

      specify do
        expect(file.read_yaml).to eq({
          "hello" => "world",
          "world" => "hello"
        })
      end
    end
  end

  #

  describe "#read_json" do
    before do
      file.rm_rf
    end

    #

    context "when the file doesn't exist" do
      context "and the user doesn't set throw_missing" do
        specify do
          expect(file.read_json).to eq({
            #
          })
        end
      end

      #

      context "and the user sets throw_missing" do
        specify do
          expect { file.read_json(:throw_missing => true) }.to raise_error(
            Errno::ENOENT
          )
        end
      end
    end

    #

    context do
      before do
        file.write({
          :hello => :world,
          :world => :hello
        }.to_json)
      end

      #

      specify do
        expect(file.read_yaml).to eq({
          "hello" => "world",
          "world" => "hello"
        })
      end
    end
  end

  #

  describe "#split_path" do
    specify do
      expect(subject.split_path).to eq [
        "", "tmp"
      ]
    end
  end

  #

  describe "#===" do
    specify do
      expect(subject === subject.basename).to eq(
        false
      )
    end

    #

    specify do
      expect(subject === Pathname.new(subject)).to eq(
        false
      )
    end

    #

    specify do
      expect(subject === subject).to eq(
        true
      )
    end
  end

  #

  describe "#==" do
    specify do
      expect(subject == subject.to_s).to eq(
        true
      )
    end

    #

    specify do
      expect(subject == Pathname.new(subject)).to eq(
        false
      )
    end

    #

    specify do
      expect(subject == subject).to eq(
        true
      )
    end
  end

  #

  describe "#>=" do
    specify do
      expect(subject >= alt).to eq(
        false
      )
    end

    #

    specify do
      expect(subject.join(alt.basename) >= subject).to eq(
        true
      )
    end

    #

    specify do
      expect(subject >= subject).to eq(
        true
      )
    end
  end

  #

  describe "#>" do
    specify do
      expect(subject > alt).to eq(
        false
      )
    end

    #

    specify do
      expect(subject.join(alt.basename) > subject).to eq(
        true
      )
    end

    #

    specify do
      expect(subject > subject).to eq(
        false
      )
    end
  end

  #

  describe "#<=>" do
    specify do
      expect(subject <=> subject.to_s).to eq(
        0
      )
    end

    #

    specify do
      expect(subject <=> subject).to eq(
        0
      )
    end
  end

  #

  describe "#<=" do
    specify do
      expect(subject <= alt.join(subject.basename)).to eq(
        false
      )
    end

    #

    specify do
      expect(subject <= subject).to eq(
        true
      )
    end

    #

    specify do
      expect(subject <= subject.join(alt.basename)).to eq(
        true
      )
    end
  end

  #

  describe "#<" do
    specify do
      expect(subject < alt.join(subject.basename)).to eq(
        false
      )
    end

    #

    specify do
      expect(subject < subject).to eq(
        false
      )
    end

    #

    specify do
      expect(subject < subject.join(alt.basename)).to eq(
        true
      )
    end
  end

  #

  describe "#absolute?" do
    specify do
      expect(subject.basename.absolute?).to eq(
        false
      )
    end

    #

    specify do
      expect(subject.absolute?).to eq(
        true
      )
    end
  end

  #

  describe "#ascend" do
    specify do
      expect { |b| subject.ascend(&b) }.to yield_successive_args(
        subject, subject.dirname
      )
    end

    #

    specify do
      expect { |b| subject.basename.ascend(&b) }.to yield_successive_args(
        subject.basename
      )
    end

    #

    specify do
      expect(subject.ascend).to be_a(
        Enumerator
      )
    end
  end

  #

  describe "#descend" do
    specify do
      expect { |b| subject.descend(&b) }.to yield_successive_args(
        subject.dirname, subject
      )
    end

    #

    specify do
      expect { |b| subject.basename.descend(&b) }.to yield_successive_args(
        subject.basename
      )
    end

    #

    specify do
      expect(subject.descend).to be_a(
        Enumerator
      )
    end
  end

  #

  describe "#each_line" do
    specify do
      expect(file.each_line).to be_a(
        Enumerator
      )
    end

    #

    specify do
      expect { |b| file.each_line(&b) }.to yield_successive_args(
        "#{alt.basename}\n", subject.basename
      )
    end
  end

  #

  describe "#fnmatch?" do
    specify do
      expect(subject.fnmatch?(subject.to_s)).to eq(
        true
      )
    end

    #

    specify do
      expect(subject.fnmatch?(subject.to_regexp)).to eq(
        true
      )
    end

    #

    specify do
      expect(subject.fnmatch?(subject)).to eq(
        true
      )
    end
  end

  #

  describe "#root?" do
    specify do
      expect(subject.parent.expand_path.root?).to eq(
        true
      )
    end

    #

    specify do
      expect(subject.root?).to eq(
        false
      )
    end
  end

  #

  describe "#in_path?" do
    specify do
      expect(subject.in_path?(subject.parent)).to eq(
        true
      )
    end

    #

    specify do
      expect(subject.in_path?(subject.join(alt.basename))).to eq(
        false
      )
    end

    #

    specify do
      expect(subject.in_path?(subject)).to eq(
        true
      )
    end

    #

    context "when given a symlink" do
      context "when the link leads to a file in our path" do
        let :tmpdir1 do
          described_class.new(
            Dir.mktmpdir
          )
        end

        #

        let :tmpdir2 do
          described_class.new(
            Dir.mktmpdir
          )
        end

        #

        before do
          file = File.join(tmpdir1, alt)
          FileUtils.touch   file
          FileUtils.symlink file, File.join(
            tmpdir2, alt
          )
        end

        #

        specify do
          expect(tmpdir2.join(alt).in_path?(tmpdir1)).to eq(
            true
          )
        end

        #

        after do
          tmpdir1.rm_rf
          tmpdir2.rm_rf
        end
      end

      #

      context "when given a link that isn't in our root" do
        let :dir do
          file
        end

        #

        before do
          dir.rm_rf
          dir.mkdir
          subject.join(alt).touch
          subject.join(alt).make_symlink(
            dir.join(alt)
          )
        end

        it do
          expect(dir.join(alt).in_path?(dir)).to eq(
            false
          )
        end

        #

        after do
          subject.join(alt).rm_rf
        end
      end
    end
  end

  #

  describe "#children" do
    specify do
      other = Pathname.new(subject).children.sort.map(&:to_s)
      expect(subject.children.sort.map(&:to_s)).to eq(
        other
      )
    end
  end

  #

  describe "#glob" do
    context do
      it "should chdir before running the glob" do
        expect(subject).to receive(
          :chdir
        )
      end

      #

      after do
        subject.glob("*").to_a
      end
    end

    #

    specify do
      expect(subject.glob("*")).to be_a(
        Enumerator
      )
    end

    #

    specify do
      expect(subject.glob("*").to_a.map(&:to_s).sort).to match(
        Dir.glob(subject.join("*")).sort
      )
    end

    #

    specify do
      expect { |b| subject.glob("*", &b) }.to yield_successive_args(
        *([described_class] * Dir.glob(subject.join("*")).size)
      )
    end
  end

  #

  describe "#chdir" do
    context do
      before do
        @old = Dir.pwd
        subject.chdir
      end

      #

      specify do
        expect(Dir.pwd).to eq(
          subject.to_s
        )
      end

      #

      after do
        Dir.chdir(
          @old
        )
      end
    end

    #

    specify do
      subject.chdir do
        expect(Dir.pwd).to eq(
          subject.to_s
        )
      end
    end
  end

  #

  describe "#find" do
    specify do
      expect(subject.find).to be_a(
        Enumerator
      )
    end

    #

    specify do
      expect(subject.find.to_a.map(&:to_s).sort).to eq(
        Pathname.new(subject).find.to_a.map(&:to_s).sort
      )
    end
  end

  #

  describe "#each_filename" do
    specify do
      expect(subject.each_filename).to be_a(
        Enumerator
      )
    end

    #

    specify do
      expect(subject.each_filename.to_a).to eq [
        subject.basename.to_s
      ]
    end

    #

    specify do
      expect { |b| subject.each_filename(&b) }.to yield_with_args(
        subject.basename.to_s
      )
    end
  end

  #

  describe "#split" do
    specify do
      expect(subject.split).to eq [
        subject.dirname, subject.basename
      ]
    end
  end

  #

  describe "#sub_ext" do
    specify do
      expect(subject.sub_ext(".rb").to_s).to eq(
        "#{subject.to_s}.rb"
      )
    end

    #

    specify do
      expect(described_class.new("hello.txt").sub_ext(".rb").to_s).to eq(
        "hello.rb"
      )
    end
  end

  #

  describe "#relative_path_from" do
    specify do
      expect(subject.join(alt.basename).relative_path_from(subject)).to eq(
        alt.basename
      )
    end

    #

    specify do
      expect(subject.relative_path_from(alt)).to eq(
        subject
      )
    end
  end

  #

  describe "#enforce_root" do
    specify do
      expect(subject.enforce_root(alt)).to eq(
        alt.join(subject)
      )
    end

    #

    specify do
      expect(subject.enforce_root(subject)).to eq(
        subject
      )
    end
  end

  #

  describe "#read" do
    specify do
      expect(file.read).to eq(
        File.read file
      )
    end

    #

    context "when set to normalize" do
      before do
        allow(file).to receive(:normalize).and_return :read => true
        file.write("hello\r\nworld")
      end

      #

      specify do
        expect(file.read).to eq(
          "hello\nworld"
        )
      end
    end

    #

    context "with an encoding argument" do
      specify do
        expect(file.read(:encoding => "ASCII").encoding.to_s).to eq(
          "US-ASCII"
        )
      end
    end

    #

    context "with a local-global encoding" do
      before do
        allow(file).to receive :encoding do
          "ASCII"
        end
      end

      #

      specify do
        expect(file.read.encoding.to_s).to eq(
          "US-ASCII"
        )
      end
    end

    #

    context "with a global encoding" do
      before do
        allow(described_class).to receive :encoding do
          "ASCII"
        end
      end

      #

      specify do
        expect(described_class.new(file).read.encoding.to_s).to eq(
          "US-ASCII"
        )
      end
    end
  end

  #

  describe "#write" do
    context "when set to normalize write" do
      before do
        allow(file).to receive(:normalize).and_return :write => true
        file.write("hello\nworld")
      end

      #

      specify do
        expect(file.read).to eq(
          "hello\r\nworld"
        )
      end
    end

    #

    context "with an encoding argument" do
      before do
        file.write("hello", {
          :encoding => "ASCII"
        })
      end

      #

      specify do
        expect(`file -i #{file.shellescape}`).to match(
          /charset=us-ascii$\n/
        )
      end
    end

    #

    context "with a local-global encoding" do
      before do
        allow(file).to receive(:encoding).and_return "ASCII"
        file.write("hello")
      end

      #

      specify do
        expect(`file -i #{file.shellescape}`).to match(
          /charset=us-ascii$\n/
        )
      end
    end

    #

    context "with global encoding" do
      before do
        allow(described_class).to receive(:encoding).and_return "ASCII"
        described_class.new(file).write("hello")
      end

      #

      specify do
        expect(`file -i #{file.shellescape}`).to match(
          /charset=us-ascii$\n/
        )
      end
    end
  end

  describe "#safe_copy" do
    context "when given a directory" do
      subject do
        tmpdir1
      end

      #

      let :tmpfile1 do
        described_class.new(
          Tempfile.new("spec").to_path
        )
      end

      #

      let :tmpdir1 do
        described_class.new(
          Dir.mktmpdir
        )
      end

      #

      let :tmpdir2 do
        described_class.new(
          Dir.mktmpdir
        )
      end

      #

      let :name1 do
        subject.join(
          tmpdir1.basename
        )
      end

      #

      let :name2 do
        subject.join(
          tmpdir2.basename
        )
      end

      #

      context "normal copying" do
        before do
          name1.mkdir_p
          name2.mkdir_p

          name1.join(name2.basename).mkdir_p
          name1.join(name2.basename, name1.basename).touch
          name1.join(name1.basename).touch

          name1.safe_copy(name2, {
            :root => tmpdir1
          })
        end

        #

        specify do
          name1.children.map { |path| path.gsub(/#{name1.regexp_escape}/, name2) }.each do |file|
            expect(file).to exist
          end
        end
      end

      #

      context "with symlinks out of the path" do
        context "when it's a file" do
          before do
            tmpfile1.touch
            tmpfile1.symlink(
              name1
            )
          end

          #

          specify do
            expect { name1.safe_copy(name2, :root => tmpdir1) }.to raise_error(
              Errno::EPERM
            )
          end
        end

        #

        context "when it's a directory" do
          context "it the symlink" do
            before do
              tmpdir2.symlink(
                name1
              )
            end

            #

            specify do
              expect { name1.safe_copy(name2, :root => tmpdir1) }.to raise_error(
                Errno::EPERM
              )
            end
          end

          #

          context "with a file" do
            before do
              name1.mkdir_p
              tmpfile1.symlink(name1.join(
                name1.basename
              ))
            end

            #

            specify do
              expect { name1.safe_copy(name2, :root => tmpdir1) }.to raise_error(
                Errno::EPERM
              )
            end
          end

          #

          context "with a directory" do
            before do
              name1.mkdir_p
              tmpdir2.symlink(name1.join(
                name1.basename
              ))
            end

            #

            specify do
              expect { name1.safe_copy(name2, :root => tmpdir1) }.to raise_error(
                Errno::EPERM
              )
            end
          end

          #

          context "when embedded deeply" do
            before do
              name1.join(name1.basename) \
                   .join(name1.basename) \
                   .mkdir_p

              tmpdir2.symlink(
              name1.join(name1.basename) \
                   .join(name1.basename) \
                   .join(name1.basename)
              )
            end

            #

            specify do
              expect { name1.safe_copy(name2, :root => tmpdir1) }.to raise_error(
                Errno::EPERM
              )
            end
          end
        end
      end

      #

      after do
        [tmpdir1, tmpdir2, tmpfile1, name1, name2].map(
          &:rm_rf
        )
      end
    end
  end
end
