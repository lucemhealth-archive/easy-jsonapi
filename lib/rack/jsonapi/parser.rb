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
    def self.parse_request!(env)
      req = Rack::Request.new(env)
      param_collection = RackReqParamsParser.parse!(req.params)
      header_collection = HeadersParser.parse!(env)
      document = DocumentParser.parse!(req.body.read)
      JSONAPI::Request.new(env, param_collection, header_collection, document)
    end
  
  end
end
