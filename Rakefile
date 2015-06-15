require "bundler/gem_tasks"

desc "Create tag v#{Hookit::VERSION}"
task :tag do
  
  puts "tagging version v#{Hookit::VERSION}"
  `git tag -a v#{Hookit::VERSION} -m "Version #{Hookit::VERSION}"`
  `git push origin --tags`
  
end
