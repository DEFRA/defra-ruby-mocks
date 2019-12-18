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

  s.add_dependency "rails", "~> 4.2.11.1"

  # Allows us to automatically generate the change log from the tags, issues,
  # labels and pull requests on GitHub. Added as a dependency so all dev's have
  # access to it to generate a log, and so they are using the same version.
  # New dev's should first create GitHub personal app token and add it to their
  # ~/.bash_profile (or equivalent)
  # https://github.com/skywinder/github-changelog-generator#github-token
  s.add_development_dependency "github_changelog_generator"

  s.add_development_dependency "defra_ruby_style"
end
