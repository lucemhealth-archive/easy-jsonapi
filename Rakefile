# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'yard'

task default: %i[test build document]

RSpec::Core::RakeTask.new(:test) do |t|
  t.verbose = false
end

task :build do
  system('gem build easy-jsonapi.gemspec')
end

YARD::Rake::YardocTask.new(:document) do |t|
  t.files = ['lib/**/*.rb'] # optional
  t.options = ['--title', "YARD #{YARD::VERSION} Documentation", '--markup=markdown'] # optional
  t.stats_options = ['--list-undoc'] # optional
end
