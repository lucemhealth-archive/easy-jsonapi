# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

task default: %i[spec build document]

RSpec::Core::RakeTask.new(:spec)


task :build do
  system('gem build rack-jsonapi.gemspec')
  system('gem install rack-jsonapi-0.1.1.gem')
end

YARD::Rake::YardocTask.new(:document) do |t|
  t.files = ['lib/**/*.rb'] # optional
  t.options = ['--any', '--extra', '--opts', '--reload', '--markup=markdown'] # optional
  t.stats_options = ['--list-undoc']         # optional
end
