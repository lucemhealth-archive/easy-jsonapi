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
    
    # If there is a JSONAPI-compliant body, it checks it for compliance and raises
    #   and error if it is found to be compliant. It 
    # @param env The rack envirornment hash
    def call(env)

      req = nil
      if requesting_jsonapi_response?(env) || includes_jsonapi_document?(env)
        req = Rack::Request.new(env)
      end
      
      check_query_param_compliance(req)
      check_req_body_compliance(req, env)

      @app.call(env)
    end

    private

    # @param req [Rack::Request | NilClass] The rack request
    # @raise If the query parameters are not JSONAPI compliant
    def check_query_param_compliance(req)
      return if req.nil?
      JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(req.params)
    end

    # @req (see #check_query_param_compliance)
    # @raise If the document body is not JSONAPI compliant
    def check_req_body_compliance(req, env)
      return if req.nil?
      req_body = Oj.load(req.body.read, symbol_keys: true)
      req.body.rewind
      http_method_is_post = env['REQUEST_METHOD'] == 'POST'
      JSONAPI::Exceptions::DocumentExceptions.check_compliance(req_body, http_method_is_post: http_method_is_post)
    end

    # Determines whether there is a request body, and whether the Content-Type is jsonapi compliant
    # @param (see #call)
    # @return [TrueClass | FalseClass] Whether the document body is supposed to be jsonapi
    def includes_jsonapi_document?(env)
      JSONAPI::Exceptions::HeadersExceptions.check_compliance(env)
      env['CONTENT_TYPE'] == 'application/vnd.api+json'
    end

    # Determines whether the request is JSONAPI or not by looking at
    #   the ACCEPT header.
    # @env (see #call)
    # @return [TrueClass | FalseClass] Whether or not the request is JSONAPI
    def requesting_jsonapi_response?(env)
      accept_arr = env['HTTP_ACCEPT'].split(',')
      accept_arr.include? 'application/vnd.api+json'
    end
    
  end
end
