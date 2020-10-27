# frozen_string_literal: true

require 'rack/jsonapi/parser/rack_req_params_parser'
require 'rack/jsonapi/parser/headers_parser'
require 'rack/jsonapi/parser/document_parser'
require 'rack/jsonapi/request'
require 'rack'
require 'oj'

module JSONAPI

  # Namespace for parsing logic in rack middleware
  # @!visibility private
  module Parser
    
    # @returns [JSONAPI::Request] the instantiated jsonapi request object
    # @query_param env [Hash] The rack envirornment hash
    # @query_param document_included [TrueClass | FalseClass] Whether or not a document
    #   was included with the request
    def self.parse_request!(env, jsonapi_doc_included: true)
      req = Rack::Request.new(env)
      
      query_param_collection = RackReqParamsParser.parse!(req.params)
      header_collection = HeadersParser.parse!(env)
      
      req_body = Oj.load(req.body.read, symbol_keys: true) # stored separately because can only read 1x
      is_post_request = env['REQUEST_METHOD'] == 'POST'
      document = jsonapi_doc_included ? DocumentParser.parse!(req_body, is_post_request) : nil
      
      JSONAPI::Request.new(env, query_param_collection, header_collection, document)
    end
  
  end
end
