require "bundler/gem_tasks"
require 'rake/testtask'

desc "Create tag v#{Hookit::VERSION}"
task :tag do
  
  puts "tagging version v#{Hookit::VERSION}"
  `git tag -a v#{Hookit::VERSION} -m "Version #{Hookit::VERSION}"`
  `git push origin --tags`
  
end

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test