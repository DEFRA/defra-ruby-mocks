# frozen_string_literal: true

source "https://rubygems.org"

# Declare your gem's dependencies in defra_ruby_mocks.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

group :development do
  gem "defra_ruby_style"
  gem "github_changelog_generator"
  gem "pry-byebug"
end

group :development, :test do
  gem "rspec-rails"
  gem "rubocop-rspec"
end

group :test do
  gem "faker"
  gem "rails-controller-testing"
  gem "simplecov"
  gem "timecop"
end
