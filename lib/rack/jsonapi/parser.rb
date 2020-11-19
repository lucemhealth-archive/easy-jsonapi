# frozen_string_literal: true

require 'rack/jsonapi/parser/rack_req_params_parser'
require 'rack/jsonapi/parser/headers_parser'
require 'rack/jsonapi/parser/document_parser'
require 'rack/jsonapi/request'

require 'rack'
require 'oj'

module JSONAPI

  # Parsing logic in rack middleware
  module Parser
    
    # @return [JSONAPI::Request] the instantiated jsonapi request object
    # @param env [Hash] The rack envirornment hash
    def self.parse_request(env)
      req = Rack::Request.new(env)
      
      query_param_collection = RackReqParamsParser.parse(req.params)
      header_collection = HeadersParser.parse(env)
      
      req_body = Oj.load(req.body.read, symbol_keys: true) # stored separately because can only read 1x
      document = includes_jsonapi_document?(env) ? DocumentParser.parse(req_body) : nil
      
      JSONAPI::Request.new(env, query_param_collection, header_collection, document)
    end

    # Is the content type jsonapi?
    # @param (see #parse_request)
    # @return [TrueClass | FalseClass]
    def self.includes_jsonapi_document?(env)
      env['CONTENT_TYPE'] == 'application/vnd.api+json'
    end

    private_class_method :includes_jsonapi_document?
  
  end
end
