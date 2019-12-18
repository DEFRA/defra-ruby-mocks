$:.push File.expand_path("../lib", __FILE__)

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

  s.add_dependency "rails", "~> 4.2.11.1"

  s.add_development_dependency "defra_ruby_style"
end
