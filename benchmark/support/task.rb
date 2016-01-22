# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8
# ----------------------------------------------------------------------------

class BenchmarkTask
  def initialize(name)
    @slower = []
    @faster = []
    @name = name
    @lines = 1
    setup_desc
    setup_task
  end

  # --------------------------------------------------------------------------

  def setup_task
    Rake::Task.define_task(@name) do
      $stdout.puts "Running benchmark files in benchmark/*.rb", ""
      Dir[File.join(File.expand_path("benchmark"), "*.rb")].each do |file|
        run file
      end

      FileUtils.rm_f("benchmark.json")
      $stdout.puts "", ""
      print_faster
      print_slower
    end
  end

  # --------------------------------------------------------------------------

  def setup_desc
    Rake.application.last_description = "Run benchmark/* and grade your speed."
  end

  # --------------------------------------------------------------------------

  private
  def print_slower
    $stdout.puts "Slower than: #{@slower.size}"
    arrange(@slower).each do |val|
      $stdout.puts " #{val.gsub(
        /^(A|B):/, ""
      )}"
    end

    $stdout.puts
  end

  # --------------------------------------------------------------------------

  def print_faster
    $stdout.puts "Faster than: #{@faster.size}"
  end

  # --------------------------------------------------------------------------

  private
  def run(file)
    _, err, = command "bundle", "exec", "ruby", file
    json = JSON.load(File.read("benchmark.json")).max_by do |val|
      val["ips"]
    end

    reset_add!
    abort err unless err.empty?
    if json["name"] =~ /^B:/
      $stdout.print " ", Simple::Ansi.green("\u2714")
      @faster << json[
        "name"
      ]

    else
      $stdout.print " ", Simple::Ansi.red("\u2718")
      @slower << json[
        "name"
      ]
    end
  end

  # --------------------------------------------------------------------------

  private
  def reset_add!
    return @lines+=1 unless @lines == 80
    $stdout.puts
    @lines = 1
  end

  # --------------------------------------------------------------------------

  private
  def command(*args)
    i, o, e, p = Open3.popen3(*args)
    out = o.read.strip
    err = e.read.strip
    [i, o, e].map(
      &:close
    )

    return [
      out, err, p.value
    ]
  end

  # --------------------------------------------------------------------------

  private
  def arrange(array)
    a = []
    b = []

    array.sort_by(&:size).each_with_index do |val, index|
      index.even?? a << val : b << val
    end

    b.push(
      *a.reverse
    )
  end
end
