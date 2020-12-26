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

      if jsonapi_request?(env)
        error_response = check_compliance(env)
        return error_response unless error_response.nil?
      end

      @app.call(env)
    end

    private

    # If the Content-type or Accept header values include the JSON:API media type without media 
    #   parameters, then it is a jsonapi request.
    # @param (see #call)
    def jsonapi_request?(env)
      accept_header_jsonapi?(env) || content_type_header_jsonapi?(env)
    end

    # Determines whether there is a request body, and whether the Content-Type is jsonapi compliant.
    # @param (see #call)
    # @return [TrueClass | FalseClass] Whether the document body is supposed to be jsonapi
    def content_type_header_jsonapi?(env)
      return false unless env['CONTENT_TYPE']
      return false unless env['CONTENT_TYPE'].include? 'application/vnd.api+json'
      env['CONTENT_TYPE'] == 'application/vnd.api+json'
    end

    # Determines whether the request is JSONAPI or not by looking at
    #   the ACCEPT header.
    # @env (see #call)
    # @return [TrueClass | FalseClass] Whether or not the request is JSONAPI
    def accept_header_jsonapi?(env)
      raise 'GET requests must have an ACCEPT header' unless env['HTTP_ACCEPT']
      accept_arr = env['HTTP_ACCEPT'].split(',')
      accept_arr.any? { |hdr| hdr.include?('application/vnd.api+json') }
    end

    # Checks whether the request is JSON:API compliant and raises an error if not.
    # @param (see #call)
    # @return [NilClass | Array] Nil meaning no error or a 400 level http response
    def check_compliance(env)
      header_error = check_headers_compliance(env)
      return header_error unless header_error.nil?

      req = Rack::Request.new(env)

      param_error = check_query_param_compliance(req, env)
      return param_error unless param_error.nil?
      
      body_error = check_req_body_compliance(req, env)
      return body_error unless body_error.nil?
    end

    # Checks whether the http headers are jsonapi compliant
    # @param (see #call)
    # @return [NilClass | Array] Nil meaning no error or a 400 level http response
    def check_headers_compliance(env)
      JSONAPI::Exceptions::HeadersExceptions.check_compliance(env)
    rescue JSONAPI::Exceptions::HeadersExceptions::InvalidHeader => e
      raise if environment_development?(env)
      [e.status_code, {}, []] 
    end

    # @param req [Rack::Request | NilClass] The rack request
    # @raise If the query parameters are not JSONAPI compliant
    # @return [NilClass | Array] Nil meaning no error or a 400 level http response
    def check_query_param_compliance(req, env)
      JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(req.GET)
    rescue JSONAPI::Exceptions::QueryParamsExceptions::InvalidQueryParameter
      raise if environment_development?(env)
      
      [400, {}, []] 
    end

    # @param env (see #call)
    # @param req (see #check_query_param_compliance)
    # @raise If the document body is not JSONAPI compliant
    def check_req_body_compliance(req, env)
      if post_put_or_patch?(env) && env['CONTENT_TYPE'].nil?
        raise 'POST, PUT, or PATCH sent without body'
      end
      raise 'GET requests cannot include a body' if env['REQUEST_METHOD'] == 'GET'
      
      req_body = Oj.load(req.body.read, symbol_keys: true)
      req.body.rewind
      http_method_is_post = env['REQUEST_METHOD'] == 'POST'
      JSONAPI::Exceptions::DocumentExceptions.check_compliance(req_body, http_method_is_post: http_method_is_post)
    rescue JSONAPI::Exceptions::DocumentExceptions::InvalidDocument
      raise if environment_development?(env)
      [400, {}, []]
    rescue Oj::ParseError
      raise if environment_development?(env)
      [400, {}, []]
    end

    def post_put_or_patch?(env)
      env['REQUEST_METHOD'] == 'POST' ||
        env['REQUEST_METHOD'] == 'PATCH' ||
        env['REQUEST_METHOD'] == 'PUT'
    end

    def environment_development?(env)
      env["RACK_ENV"] == :development || env["RACK_ENV"].nil?
    end
  end
end
