# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'yard'

task default: %i[test build document]

RSpec::Core::RakeTask.new(:test) do |t|
  t.verbose = false
end

task :build do
  system('gem build rack-jsonapi.gemspec')
  system('gem install rack-jsonapi-0.1.1.gem')
end

YARD::Rake::YardocTask.new(:document) do |t|
  t.files = ['lib/**/*.rb'] # optional
  t.options = ['--title', "YARD #{YARD::VERSION} Documentation", '--markup=markdown'] # optional
  t.stats_options = ['--list-undoc'] # optional
end

task :generate_serializer do
  class Renderer 
    attr_reader :template, :name

    def initialize
      @template = File.open('template.erb', 'rb', &:read)
      @name = "Jonathan"
    end

    def benediction
      Time.now.hour >= 12 ? "Have a wonderful afternoon!" : "Have a wonderful morning!"
    end

    def render
      ERB.new(template).result(binding)
    end 
  end

  pp Render.new.render
end
