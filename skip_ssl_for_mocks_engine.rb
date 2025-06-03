# frozen_string_literal: true

module Middleware

  class SkipSSLForMocksEngine
    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)

      # If the request is to the engine's path AND it's over HTTP
      if req.scheme == "http" && req.path.match(%r{/[bo|f]/mocks/})
        # Pretend the request is HTTPS to skip ActionDispatch::SSL redirection
        env["HTTPS"] = "on"
        env["rack.url_scheme"] = "https"
        env["SERVER_PORT"] = "443"
      end

      @app.call(env)
    end
  end
end
