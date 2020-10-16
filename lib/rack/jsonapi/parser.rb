# frozen_string_literal: true

require 'rack/jsonapi/parser/rack_req_params_parser'
require 'rack/jsonapi/parser/headers_parser'
require 'rack/jsonapi/parser/document_parser'
require 'rack/jsonapi/request'

require 'rack'

module JSONAPI

  # Namespace for parsing logic in rack middleware
  # @!visibility private
  module Parser
    
    # @return [JSONAPI::Request] the instantiated jsonapi request object
    # @param document_included [TrueClass | FalseClass] Whether or not a document
    #   was included with the request
    def self.parse_request!(env, document_included)
      req = Rack::Request.new(env)
      param_collection = RackReqParamsParser.parse!(req.params)
      header_collection = HeadersParser.parse!(env)
      document = document_included ? DocumentParser.parse!(req.body.read) : nil
      JSONAPI::Request.new(env, param_collection, header_collection, document)
    end
  
  end
end
