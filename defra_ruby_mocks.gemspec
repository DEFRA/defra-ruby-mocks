# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "defra_ruby_mocks/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "defra_ruby_mocks"
  s.version     = DefraRubyMocks::VERSION
  s.authors     = ["Defra"]
  s.email       = ["alan.cruikshanks@environment-agency.gov.uk"]
  s.homepage    = "https://github.com/DEFRA/defra-ruby-mocks"
  s.summary     = "Defra Ruby on Rails external API mocking engine"
  s.description = "A Rails engine which can be used to mock external services when loaded into an application"
  s.license     = "The Open Government Licence (OGL) Version 3"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.required_ruby_version = ">= 3.2.2"

  s.add_dependency "rails", "~> 7.0"

  # sprockets-4.0.0 requires ruby version >= 2.5.0, which is incompatible with
  # the current version, ruby 2.4.2p198
  s.add_dependency "sprockets"
  s.add_dependency "sprockets-rails"

  s.add_dependency "defra_ruby_aws"

  s.metadata["rubygems_mfa_required"] = "true"
end
