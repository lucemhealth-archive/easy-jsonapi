# frozen_string_literal: true

task default: %i[build]

# RSpec::Core::RakeTask.new(:spec)


task :build do
  system('gem build rack-jsonapi.gemspec')
  system('gem install rack-jsonapi-0.1.1.gem')
end

# YARD::Rake::YardocTask.new(:document) do |t|
#   t.files = ['lib/**/*.rb'] # optional
#   t.options = ['--any', '--extra', '--opts', '--reload', '--markup=markdown'] # optional
#   t.stats_options = ['--list-undoc']         # optional
# end
