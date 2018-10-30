namespace :missing do
  desc "List methods we are missing."
  task :methods do
    methods = Pathname.instance_methods - Pathutil.instance_methods - Object.instance_methods
    methods-= [
      :cleanpath
    ]

    methods.each do |method|
      $stdout.puts method
    end
  end
end
