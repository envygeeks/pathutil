namespace :pathname do
  desc "List all of Pathnames methods."
  task :methods do
    methods = Pathname.instance_methods - Object.instance_methods
    methods.each_with_index do |method, index|
      $stdout.print method
      unless index == methods.size - 1
        $stdout.print ", "
      end
    end

    $stdout.puts
  end
end
