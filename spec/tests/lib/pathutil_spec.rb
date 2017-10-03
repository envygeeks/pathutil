# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8

require "rspec/helper"
require "yaml"

describe Pathutil do
  (Pathname.instance_methods - Object.instance_methods).each do |method|
    it "should have #{method}" do
      expect(described_class).to have_method(
        method
      )
    end
  end

  #

  let :file do
    described_class.new(described_class.make_tmpname(
      "pathutil", "spec"
    ))
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

  describe "absolute" do
    it "should make paths absolute with /" do
      expect(described_class.new("hello/world").absolute).to eq(
        "/hello/world"
      )
    end

    #

    context "when given a Windows root" do
      it "should not add / in the front" do
        expect(described_class.new("C:\\hello\\world").absolute).to eq(
          "C:\\hello\\world"
        )
      end
    end
  end

  #

  describe "#relative" do
    it "should make paths relative" do
      expect(described_class.new("/hello/world").relative).to eq(
        "hello/world"
      )
    end

    #

    it "should strip the Windows drive too!" do
      expect(described_class.new("C:/hello/world").relative).to eq(
        "hello/world"
      )
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

    context "when the file doesn't exist" do
      context "and the user doesn't set throw_missing" do
        it "should return a blank hash as if nothing actually went wrong" do
          expect(file.read_yaml).to eq({
            #
          })
        end
      end

      #

      context "and the user sets throw_missing" do
        it "should throw the parse" do
          expect { file.read_yaml(throw_missing: true) }.to raise_error(
            Errno::ENOENT
          )
        end
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
        it "should return a blank hash as if nothing actually went wrong" do
          expect(file.read_json).to eq({
            #
          })
        end
      end

      #

      context "and the user sets throw_missing" do
        it "should throw the parse" do
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

      it "should parse JSON" do
        expect(file.read_yaml).to eq({
          "hello" => "world",
          "world" => "hello"
        })
      end
    end
  end

  #

  describe "#split_path" do
    it "should split the path and return that result" do
      expect(subject.split_path).to eq [
        "", "tmp"
      ]
    end
  end

  # --
  # rubocop:disable Lint/UselessComparison
  # rubocop:disable Style/CaseEquality
  # --

  describe "#===" do
    it "should match itself" do
      expect(subject === subject.basename).to eq(
        false
      )
    end

    #

    it "should not match another" do
      expect(subject === Pathname.new(subject)).to eq(
        false
      )
    end

    #

    it "should match" do
      expect(subject === subject).to eq(
        true
      )
    end
  end

  # --
  # rubocop:enable Style/CaseEquality
  # --

  describe "#==" do
    it "should match strings" do
      expect(subject == subject.to_s).to eq(
        true
      )
    end

    #

    it "should not match classes" do
      expect(subject == Pathname.new(subject)).to eq(
        false
      )
    end

    #

    it "should match itself" do
      expect(subject == subject).to eq(
        true
      )
    end
  end

  #

  describe "#>=" do
    it "sholuld match paths ahead of the path" do
      expect(subject.join(alt.basename) >= subject).to eq(
        true
      )
    end

    #

    it "should not match paths that are not within one another" do
      expect(subject >= alt).to eq(
        false
      )
    end

    #

    it "should match itself" do
      expect(subject >= subject).to eq(
        true
      )
    end
  end

  #

  describe "#>" do
    it "should match paths below the path" do
      expect(subject.join(alt.basename) > subject).to eq(
        true
      )
    end

    #

    it "should not match paths that are not within one another" do
      expect(subject > alt).to eq(
        false
      )
    end

    #

    it "should not match itself" do
      expect(subject > subject).to eq(
        false
      )
    end
  end

  #

  describe "#<=>" do
    it "should match strings" do
      expect(subject <=> subject.to_s).to eq(
        0
      )
    end

    #

    it "should match itself" do
      expect(subject <=> subject).to eq(
        0
      )
    end
  end

  #

  describe "#<=" do
    it "should not match paths not within one another" do
      expect(subject <= alt).to eq(
        false
      )
    end

    #

    it "should match itself" do
      expect(subject <= subject).to eq(
        true
      )
    end

    #

    it "should match pathes below but within itself" do
      expect(subject <= subject.join(alt.basename)).to eq(
        true
      )
    end
  end

  #

  describe "#<" do
    it "should not match paths not within one another" do
      expect(subject < alt).to eq(
        false
      )
    end

    #

    it "should not match itself" do
      expect(subject < subject).to eq(
        false
      )
    end

    #

    it "should match pathes below but within itself" do
      expect(subject < subject.join(alt.basename)).to eq(
        true
      )
    end
  end

  #

  describe "#absolute?" do
    it "should not match relative paths" do
      expect(subject.basename.absolute?).to eq(
        false
      )
    end

    #

    it "should match a path that starts with /" do
      expect(subject.absolute?).to eq(
        true
      )
    end
  end

  #

  describe "#ascend" do
    it "should break apart the path and yield each part" do
      expect { |b| subject.ascend(&b) }.to yield_successive_args(
        subject, subject.dirname
      )
    end

    #

    it "should not duplicate itself" do
      expect { |b| subject.basename.ascend(&b) }.to yield_successive_args(
        subject.basename
      )
    end

    #

    it "should ship the user an enum if no block is given" do
      expect(subject.ascend).to be_a(
        Enumerator
      )
    end
  end

  #

  describe "#descend" do
    it "should break apart the path and yield each part" do
      expect { |b| subject.descend(&b) }.to yield_successive_args(
        subject.dirname, subject
      )
    end

    #

    it "should not duplicate itself" do
      expect { |b| subject.basename.descend(&b) }.to yield_successive_args(
        subject.basename
      )
    end

    #

    it "should ship the user an enum if no block is given" do
      expect(subject.descend).to be_a(
        Enumerator
      )
    end
  end

  #

  describe "#each_line" do
    it "should ship the user an enum if no block is given" do
      expect(file.each_line).to be_a(
        Enumerator
      )
    end

    #

    it "should yield each line" do
      expect { |b| file.each_line(&b) }.to yield_successive_args(
        "#{alt.basename}\n", subject.basename
      )
    end
  end

  #

  describe "#fnmatch?" do
    it "should directly match" do
      expect(subject.fnmatch?(subject.to_s)).to eq(
        true
      )
    end

    #

    it "should regexp match" do
      expect(subject.fnmatch?(subject.to_regexp)).to eq(
        true
      )
    end

    #

    it "should object match" do
      expect(subject.fnmatch?(subject)).to eq(
        true
      )
    end
  end

  #

  describe "#root?" do
    it "should match only /" do
      expect(subject.parent.expand_path.root?).to eq(
        true
      )
    end

    #

    it "should not match any path that is not /" do
      expect(subject.root?).to eq(
        false
      )
    end
  end

  #

  describe "#in_path?" do
    it "should match a path that is deeper than but within a given path" do
      expect(subject.in_path?(subject.parent)).to eq(
        true
      )
    end

    #

    it "should not match if the reverse is given" do
      expect(subject.in_path?(subject.join(alt.basename))).to eq(
        false
      )
    end

    #

    it "should match itself" do
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

        it "should get the realpath and compare it" do
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

        it "should refute it if the realpaths are not within on another" do
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
    it "should get the files and yield them" do
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

    it "should return an enum if no block is given" do
      expect(subject.glob("*")).to be_a(
        Enumerator
      )
    end

    #

    it "should run the glob" do
      expect(subject.glob("*").to_a.map(&:to_s).sort).to match(
        Dir.glob(subject.join("*")).sort
      )
    end

    #

    it "should yield a given block with each file" do
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

      it "should chdir to the requested dir" do
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

    it "should allow the user to chdir in a block and exit that chdir" do
      old_pwd = Dir.pwd
      subject.chdir do
        expect(Dir.pwd).to eq(
          subject.to_s
        )
      end

      expect(Dir.pwd).to eq(
        old_pwd
      )
    end
  end

  #

  describe "#find" do
    it "should return an enum if no block is given" do
      expect(subject.find).to be_a(
        Enumerator
      )
    end

    #

    it "should behave like Pathname#find" do
      expect(subject.find.to_a.map(&:to_s).sort).to eq(
        Pathname.new(subject).find.to_a.map(&:to_s).sort
      )
    end
  end

  #

  describe "#each_filename" do
    it "should return an enum if no block is given" do
      expect(subject.each_filename).to be_a(
        Enumerator
      )
    end

    #

    it "should give a list of file names" do
      expect(subject.each_filename.to_a).to eq [
        subject.basename.to_s
      ]
    end

    #

    it "should yield each file name back to the given block" do
      expect { |b| subject.each_filename(&b) }.to yield_with_args(
        subject.basename.to_s
      )
    end
  end

  #

  describe "#split" do
    it "should break apart the directory and the file" do
      expect(subject.split).to eq [
        subject.dirname, subject.basename
      ]
    end
  end

  #

  describe "#sub_ext" do
    it "should add an extension even if one doesn't exist" do
      expect(subject.sub_ext(".rb").to_s).to eq(
        "#{subject}.rb"
      )
    end

    #

    it "should replace the extension with the new one" do
      expect(described_class.new("hello.txt").sub_ext(".rb").to_s).to eq(
        "hello.rb"
      )
    end
  end

  #

  describe "#relative_path_from" do
    it "should return the relative path from the given path" do
      expect(subject.join(alt.basename).relative_path_from(subject)).to eq(
        alt.basename
      )
    end

    #

    context "when the given path is not within the path" do
      it "should return the absolute path" do
        expect(subject.relative_path_from(alt)).to eq(
          subject
        )
      end
    end
  end

  #

  describe "#enforce_root" do
    it "should enforce the root to the left" do
      expect(subject.enforce_root(alt)).to eq(
        alt.join(subject)
      )
    end

    #

    it "should not double enforce the root" do
      expect(subject.enforce_root(subject)).to eq(
        subject
      )
    end
  end

  #

  describe "#read" do
    it "should read the file" do
      expect(file.read).to eq(File.read(
        file
      ))
    end

    #

    context "when set to normalize" do
      before do
        allow(file).to receive(:normalize).and_return :read => true
        file.write("hello\r\nworld")
      end

      #

      it "should use encode to convert CRLF to LF" do
        expect(file.read).to eq(
          "hello\nworld"
        )
      end
    end

    #

    context "with an encoding argument" do
      it "should set the encoding for the data stream" do
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

      it "should set the encoding for the data stream" do
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

      it "should set the encoding for the data stream" do
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

      context "when on Windows" do
        it "should convert LF to CRLF" do
          expect(file.read).to eq(
            "hello\r\nworld"
          )
        end
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

      it "should set the encoding while writing" do
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

      it "should set the encoding while writing" do
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

      it "should set the encoding while writing" do
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

      context "when asked to ignore files/folders" do
        before do
          name1.mkdir_p
          name2.mkdir_p

          name1.join(name2.basename).mkdir_p
          name1.join(name2.basename, name1.basename).touch
          name1.join(name1.basename).touch

          name1.safe_copy(name2, {
            :root => tmpdir1, :ignore => [
              name1.join(name2.basename, name1.basename)
            ]
          })
        end

        #

        it "should not copy those files" do
          expect(name2.join(name2.basename, name1.basename)).not_to(
            exist
          )
        end
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

        it "should copy all files" do
          name1.children.map { |path| path.gsub(/#{name1.regexp_escape}/, name2) }.each do |file|
            expect(file).to exist
          end
        end
      end

      #

      context "with symlinks out of the root" do
        context "when it's a file" do
          before do
            tmpfile1.touch
            tmpfile1.symlink(
              name1
            )
          end

          #

          it "should reject it" do
            expect { name1.safe_copy(name2, :root => tmpdir1) }.to raise_error(
              Errno::EPERM
            )
          end
        end

        #

        context "when it's a directory" do
          context "and it is the symlink to another node" do
            before do
              tmpdir2.symlink(
                name1
              )
            end

            #

            it "should reject it" do
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

            it "should reject it" do
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

            it "should reject it" do
              expect { name1.safe_copy(name2, :root => tmpdir1) }.to raise_error(
                Errno::EPERM
              )
            end
          end

          # --
          # rubocop:disable Style/MultilineMethodCallIndentation
          # rubocop:disable Style/FirstParameterIndentation
          # --

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

            it "should still reject it" do
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

  #

  describe ".tmpdir" do
    it "creates a temporary directory" do
      expect(described_class.tmpdir.directory?).to eq(
        true
      )
    end
  end

  #

  describe "#.tmpfile" do
    it "creates a tempoary file" do
      expect(described_class.tmpfile.file?).to eq(
        true
      )
    end
  end

  #

  describe "#.pwd" do
    it "should return the current pwd as a #{self.class.name}" do
      expect(described_class.pwd).to eq(described_class.new(
        Dir.pwd
      ))
    end
  end

  # --
  # These tests are taken from: https://github.com/ruby/ruby/blob/trunk/test/pathname/test_pathname.rb
  # The source that runs against these tests is reverse engineered since
  # their source is mighty confusing...
  # --

  describe "#aggressive_cleanpath" do
    # rubocop:disable Style/WordArray
    tests = [['/', '/'], ['.', ''], ['.', '.'], ['..', '..'], ['a', 'a'], ['/', '/.'],
      ['/', '/..'], ['/a', '/a'], ['.', './'], ['..', '../'], ['a', 'a/'], ['a/b', 'a//b'],
      ['a', 'a/.'], ['a', 'a/./'], ['.', 'a/..'], ['.', 'a/../'], ['/a', '/a/.'], ['..', './..'],
      ['..', '../.'], ['..', './../'], ['..', '.././'], ['/', '/./..'], ['/', '/../.'], ['/', '/./../'],
      ['/', '/.././'], ['a/b/c', 'a/b/c'], ['b/c', './b/c'], ['a/c', 'a/./c'], ['a/b', 'a/b/.'],
      ['.', 'a/../.'], ['/a', '/../.././../a'], ['../../d', 'a/b/../../../../c/../d'],
      ['/', '///'], ['/a', '///a'], ['/', '///..'], ['/', '///.'],
      ['/', '///a/../..'], ['c:/foo/bar', 'c:\\foo\\bar']]
      # rubocop:enable Style/WordArray

    tests.each do |(result, test)|
      specify "(#{test}) => #{result}" do
        expect(Pathutil.new(test).send(:aggressive_cleanpath).to_s).to eq(
          result
        )
      end

      #

      specify "(#{test}) matches Pathname" do
        expect(Pathutil.new(test).send(:aggressive_cleanpath).to_s).to eq(
          Pathutil.new(test).send(:aggressive_cleanpath).to_s
        )
      end
    end
  end

  # --
  # These tests are taken from: https://github.com/ruby/ruby/blob/trunk/test/pathname/test_pathname.rb
  # The source that runs against these tests is reverse engineered since
  # their source is mighty confusing...
  # --

  describe "#conservative_cleanpath" do
    # rubocop:disable Style/WordArray
    tests = [['/', '/'], ['.', ''], ['.', '.'], ['..', '..'], ['a', 'a'], ['/', '/.'],
      ['/', '/..'], ['/a', '/a'], ['.', './'], ['..', '../'], ['a/', 'a/'], ['a/b', 'a//b'],
      ['a/.', 'a/.'], ['a/.', 'a/./'], ['a/..', 'a/../'], ['/a/.', '/a/.'], ['..', './..'], ['..', '../.'],
      ['..', './../'], ['..', '.././'], ['/', '/./..'], ['/', '/../.'], ['/', '/./../'], ['/', '/.././'],
      ['a/b/c', 'a/b/c'], ['b/c', './b/c'], ['a/c', 'a/./c'], ['a/b/.', 'a/b/.'], ['a/..', 'a/../.'],
      ['c:/foo/bar', 'c:\\foo\\bar'], ['/a', '/../.././../a'],
      ['a/b/../../../../c/../d', 'a/b/../../../../c/../d']]
      # rubocop:enable Style/WordArray

    tests.each do |(result, test)|
      specify "(#{test}) => #{result}" do
        expect(Pathutil.new(test).send(:conservative_cleanpath).to_s).to eq(
          result
        )
      end

      #

      specify "(#{test}) matches Pathname" do
        expect(Pathutil.new(test).send(:aggressive_cleanpath).to_s).to eq(
          Pathutil.new(test).send(:aggressive_cleanpath).to_s
        )
      end
    end
  end
end
