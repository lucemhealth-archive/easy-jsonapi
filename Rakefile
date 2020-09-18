require "bundler/gem_tasks"
require "rspec/core/rake_task"

# RSpec::Core::RakeTask.new(:spec)

# task :default => :spec

task :default => :buildgem

task :buildgem do
    system("gem build curmid.gemspec")
    system("gem install curmid-0.1.0.gem")
end
