require "bundler/gem_tasks"

desc "Create tag v#{Hooky::VERSION}"
task :tag do
  
  puts "tagging version v#{Hooky::VERSION}"
  `git tag -a v#{Hooky::VERSION} -m "Version #{Hooky::VERSION}"`
  `git push origin --tags`
  
end

desc "Create tag v#{Hooky::VERSION} and build and push hooky-#{Hooky::VERSION}.gem to Gemfury"
task :fury => [:tag, :build] do

  puts `fury push pkg/hooky-#{Hooky::VERSION}.gem`

end