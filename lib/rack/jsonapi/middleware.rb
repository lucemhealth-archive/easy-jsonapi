# frozen_string_literal: true

require 'rack/jsonapi/exceptions'
require 'rack/jsonapi/config_manager'
require 'oj'

module JSONAPI

  # The middleware of the gem and also the contact point between the
  # the gem and the rack application using it
  class Middleware
    # @param app The Rack Application
    def initialize(app, &block)
      @app = app

      return unless block_given?

      @config_manager = JSONAPI::ConfigManager.new
      block.call(@config_manager)
    end

    # If there is a JSONAPI-compliant body, it checks it for compliance and raises
    #   and error if it is found to be compliant. It 
    # @param env The rack envirornment hash
    def call(env)
      if in_maintenance_mode?(env)
        return maintenance_response(env)
      end

      if jsonapi_request?(env)
        error_response = check_compliance(env, @config_manager)
        return error_response unless error_response.nil?
      end

      @app.call(env)
    end

    private

    # Checks the 'MAINTENANCE' environment variable
    # @param (see #call)
    # @return [TrueClass | FalseClass]
    def in_maintenance_mode?(env)
      !env['MAINTENANCE'].nil?
    end

    # Return 503 with or without msg depending on environment
    # @param (see #call)
    # @return [Array] Http Error Responses
    def maintenance_response(env)
      if environment_development?(env)
        [503, {}, ['MAINTENANCE envirornment variable set']]
      else
        [503, {}, []]
      end
    end

    # If the Content-type or Accept header values include the JSON:API media type without media 
    #   parameters, then it is a jsonapi request.
    # @param (see #call)
    def jsonapi_request?(env)
      accept_header_jsonapi?(env) || content_type_header_jsonapi?(env)
    end

    # Determines whether the request is JSONAPI or not by looking at
    #   the ACCEPT header.
    # @env (see #call)
    # @return [TrueClass | FalseClass] Whether or not the request is JSONAPI
    def accept_header_jsonapi?(env)
      return true if env['HTTP_ACCEPT'].nil? # no header means assume any

      accept_arr = env['HTTP_ACCEPT'].split(',')
      accept_arr.any? { |hdr| hdr.include?('application/vnd.api+json') }
    end

    # Determines whether there is a request body, and whether the Content-Type is jsonapi compliant.
    # @param (see #call)
    # @return [TrueClass | FalseClass] Whether the document body is supposed to be jsonapi
    def content_type_header_jsonapi?(env)
      return false unless env['CONTENT_TYPE']

      env['CONTENT_TYPE'].include? 'application/vnd.api+json'
    end

    # Checks whether the request is JSON:API compliant and raises an error if not.
    # @param env (see #call)
    # @param config_manager [JSONAPI::ConfigManager::Config] The config object to use modify compliance checking
    # @return [NilClass | Array] Nil meaning no error or a 400 level http response
    def check_compliance(env, config_manager)
      opts = { http_method: env['REQUEST_METHOD'], path: env['PATH_INFO'] }

      header_error = check_headers_compliance(env, config_manager, opts)
      return header_error unless header_error.nil?

      req = Rack::Request.new(env)
      param_error = check_query_param_compliance(env, req.GET, config_manager, opts)
      return param_error unless param_error.nil?
      
      return unless env['CONTENT_TYPE']

      body_error = check_req_body_compliance(env, config_manager, opts)
      return body_error unless body_error.nil?
    end

    # Checks whether the http headers are jsonapi compliant
    # @param (see #call)
    # @return [NilClass | Array] Nil meaning no error or a 400 level http response
    def check_headers_compliance(env, config_manager, opts)
      JSONAPI::Exceptions::HeadersExceptions.check_request(env, config_manager, opts)
    rescue JSONAPI::Exceptions::HeadersExceptions::InvalidHeader || JSONAPI::Exceptions::UserDefinedExceptions::InvalidHeader => e
      raise if environment_development?(env)

      [e.status_code, {}, []]
    end

    # @param query_params [Hash] The rack request query_param hash
    # @raise If the query parameters are not JSONAPI compliant
    # @return [NilClass | Array] Nil meaning no error or a 400 level http response
    def check_query_param_compliance(env, query_params, config_manager, opts)
      JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(query_params, config_manager, opts)
    rescue JSONAPI::Exceptions::QueryParamsExceptions::InvalidQueryParameter || JSONAPI::Exceptions::UserDefinedExceptions::InvalidQueryParam => e
      raise if environment_development?(env)
      
      [e.status_code, {}, []]
    end

    # @param env (see #call)
    # @param req (see #check_query_param_compliance)
    # @raise If the document body is not JSONAPI compliant
    def check_req_body_compliance(env, config_manager, opts)
      # Store separately so you can rewind for next middleware or app
      body = env['rack.input'].read
      env['rack.input'].rewind
      JSONAPI::Exceptions::DocumentExceptions.check_compliance(body, config_manager, opts)
    rescue JSONAPI::Exceptions::DocumentExceptions::InvalidDocument || JSONAPI::Exceptions::UserDefinedExceptions::InvalidDocument => e
      raise if environment_development?(env)

      [e.status_code, {}, []]
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
      env['RACK_ENV'].to_s.downcase == 'development' || env['RACK_ENV'].nil?
    end
  end
end
