# frozen_string_literal: true

require 'rack/jsonapi/exceptions'
require 'oj'

module JSONAPI

  # The middleware of the gem and also the contact point between the
  # the gem and the rack application using it
  class Middleware

    # @param app The Rack Application
    def initialize(app)
      @app = app
    end
    
    # @param env The rack envirornment hash
    def call(env)
      
      includes_jsonapi_doc = includes_jsonapi_document?(env)
      if includes_jsonapi_doc
        req = Rack::Request.new(env)

        JSONAPI::Exceptions::QueryParamsExceptions.check_compliance!(req.params)

        req_body = Oj.load(req.body.read, symbol_keys: true)
        req.body.rewind
        http_method_is_post = env['REQUEST_METHOD'] == 'POST'
        JSONAPI::Exceptions::DocumentExceptions.check_compliance!(req_body, http_method_is_post: http_method_is_post)
      end

      @app.call(env)
    end

    private

    # Determines whether there is a request body, and whether the Content-Type is jsonapi compliant
    # @param (see #call)
    # @return [TrueClass | FalseClass] whether 
    def includes_jsonapi_document?(env)
      JSONAPI::Exceptions::HeadersExceptions.check_compliance!(env)
      env['CONTENT_TYPE'] == 'application/vnd.api+json'
    end
    
  end
end
