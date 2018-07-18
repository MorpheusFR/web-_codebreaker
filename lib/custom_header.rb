module Rack
  class CustomHeader
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      headers['X-Custom-Header'] = 'content'

      [status, headers, body]
    end
  end
end