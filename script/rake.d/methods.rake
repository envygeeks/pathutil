desc "List all of Pathutils methods."
task :methods do
  methods = Pathutil.instance_methods - Object.instance_methods
  methods.each_with_index do |method, index|
    $stdout.print "`", method, "`"
    unless index == methods.size - 1
      $stdout.print ", "
    end
  end

  $stdout.puts
end
