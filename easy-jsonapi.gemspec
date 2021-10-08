# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'easy-jsonapi'
  spec.version       = '1.0.11' # update this upon release
  spec.authors       = ['Joshua DeMoss, Joe Viscomi']
  spec.email         = ['demoss.joshua@gmail.com']

  spec.summary       = 'Middleware, Parser, and Validator for JSONAPI requests and serialized resopnses'
  spec.description   = 'Middleware to screen non-JSONAPI-compliant requests, a parser to provide Object Oriented access to requests, and a validator for validating JSONAPI Serialized responses.'
  spec.homepage      = 'https://rubygems.org/gems/easy-jsonapi'
  spec.required_ruby_version = '>= 2.5'

  spec.metadata["source_code_uri"] = "https://github.com/Curatess/easy-jsonapi"
  spec.metadata["changelog_uri"] = "https://github.com/Curatess/easy-jsonapi/CHANGELOG.mg"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dev Dependencies
  spec.add_development_dependency 'rack', '~> 2.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'redcarpet', '~> 3.5'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 1.11'
  spec.add_development_dependency 'solargraph', '~> 0.39'
  spec.add_development_dependency 'codecov', '~> 0.4'

  # Dependencies
  spec.add_dependency 'oj', '~> 3.10'

  spec.license = 'MIT'
end
