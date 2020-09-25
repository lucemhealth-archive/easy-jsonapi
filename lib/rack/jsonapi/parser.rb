# frozen_string_literal: true

# require 'rack/jsonapi/document'

require 'rack/jsonapi/parse/parse_headers'
require 'rack/jsonapi/parser/parse_query_string'
require 'rack/jsonapi/request'

module JSONAPI

  # Namespace for parsing logic in rack middleware
  # @!visibility private
  module Parser
    
    # @return [JSONAPI::Request] the instantiated jsonapi request object
    def self.parse_request!(env)
      params, pagination, field_sets = ParseQueryString.parse!(env['QUERY_STRING'])
      headers = ParseHeaders.parse!(env)
      document = ParseDocument.parse!(env.body.read)
      Request.new(env, params, pagination, field_sets, headers, document)
    end
    
end
