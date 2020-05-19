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
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.11.1"

  # sprockets-4.0.0 requires ruby version >= 2.5.0, which is incompatible with
  # the current version, ruby 2.4.2p198
  s.add_dependency "sprockets", "~> 3.7.2"

  # Used to parse XML requests. Needed to support the Worldpay mock, as Worldpay
  # uses XML rather than JSON
  s.add_dependency "nokogiri"

  # Allows us to automatically generate the change log from the tags, issues,
  # labels and pull requests on GitHub. Added as a dependency so all dev's have
  # access to it to generate a log, and so they are using the same version.
  # New dev's should first create GitHub personal app token and add it to their
  # ~/.bash_profile (or equivalent)
  # https://github.com/skywinder/github-changelog-generator#github-token
  s.add_development_dependency "github_changelog_generator"

  s.add_development_dependency "defra_ruby_style"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rspec-rails", "~> 3.8.0"
  s.add_development_dependency "simplecov", "~> 0.17.1"
end
