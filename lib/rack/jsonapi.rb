# require "curmid/version"
require_relative "curmid/version"
require_relative "curmid/request"

module JSONAPI
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      params = "params"
      headers = "headers"
      document = "document"

      @parsed_jsonapi = {params: params, headers: headers, document: document}
      @app.instance_variable_get(:@app).instance_variable_set('@parsed_jsonapi', @parsed_jsonapi)

      @app.call(env)
    end
  end
end