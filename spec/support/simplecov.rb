# frozen_string_literal: true

require "simplecov"

# We start it with the rails param to ensure it includes coverage for all code
# started by the rails app, and not just the files touched by our unit tests.
# This gives us the most accurate assessment of our unit test coverage
# https://github.com/colszowka/simplecov#getting-started
SimpleCov.start do
  # We filter the spec folder, mainly to ensure that any dummy apps don't get
  # included in the coverage report. However our intent is that nothing in the
  # spec folder should be included
  add_filter "/spec/"
  # The version file is simply just that, so we do not feel the need to ensure
  # we have a test for it
  add_filter "lib/defra_ruby/mocks/version"
end
