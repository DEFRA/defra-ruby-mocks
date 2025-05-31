# frozen_string_literal: true

require "defra_ruby_mocks/engine"

module DefraRubyMocks
  # Enable the ability to configure the gem from its host app, rather than
  # reading directly from env vars. Derived from
  # https://robots.thoughtbot.com/mygem-configure-block
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.configure
    yield(configuration)
  end

  class Configuration

    # If the setting's value is "true", then set to a boolean true. Otherwise,
    # set it to false.
    def change_string_to_boolean_for(setting)
      setting = setting == "true" if setting.is_a?(String)
      setting
    end

    # Used to determine if engine is running in the back-office rather than the
    # front-office
    def host_is_back_office=(value)
      @host_is_back_office = change_string_to_boolean_for(value)
    end

    def host_is_back_office?
      return false unless @host_is_back_office

      @host_is_back_office
    end
  end
end
