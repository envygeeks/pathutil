namespace :diff do
  desc "List methods we have that Pathname doesn't."
  task :methods do
    methods = Pathutil.instance_methods - Pathname.instance_methods - Object.instance_methods
    methods.each do |method|
      $stdout.print "- ", "`", method, "`", "\n"
    end
  end
end
