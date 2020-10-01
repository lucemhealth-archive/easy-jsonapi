# frozen_string_literal: true

require 'rack/jsonapi/parser/parse_headers'
require 'rack/jsonapi/parser/parse_query_string'
require 'rack/jsonapi/parser/parse_document'
require 'rack/jsonapi/request'

module JSONAPI

  # Namespace for parsing logic in rack middleware
  # @!visibility private
  module Parser
    
    # @return [JSONAPI::Request] the instantiated jsonapi request object
    def self.parse_request!(env)
      # params, pagination, field_sets = ParseQueryString.parse!(env['QUERY_STRING'])
      params = "params"
      pagination = "pagination"
      field_sets = "field_sets"
      headers = ParseHeaders.parse!(env)
      document = ParseDocument.parse!(env['rack.input'].read)
      Request.new(env, params, pagination, field_sets, headers, document)
    end
  end
end
