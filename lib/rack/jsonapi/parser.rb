# frozen_string_literal: true

require 'rack/jsonapi/headers'
# require 'rack/jsonapi/document'
require 'rack/jsonapi/request'
require 'rack/jsonapi/params'
require 'rack/jsonapi/fieldsets'
require 'rack/jsonapi/pagination'

module JSONAPI

  # Namespace for parsing logic in rack middleware
  # @!visibility private
  module Parser

    # @return [JSONAPI::Request] the instantiated jsonapi request object
    def self.parse_request!(env)
      params, pagination, field_sets = ParseQueryString.parse!(env)
      headers = ParseHeaders.parse!(env)
      document = ParseDocument.parse!(env)
      Request.new(env, params, pagination, field_sets, headers, document)
    end

    # Query String Parsing Logic
    module ParseQueryString

      # @return [JSONAPI::Params, JSONAPI::Pagination, JSONAPI::FieldSets]
      def self.parse!(env)
        parsed_string = {}
        arr = env['QUERY_STRING'].split(/&|=/)
        
        i = 0
        while i < arr.length
          parsed_string[arr[i]] = arr[i + 1]
          i += 2
        end

        # parsed_string == {"incluce" => "author" ... }
        parse_helper!(parsed_string)
      end

      # @param [Hash<String, String>] String hash of parsed query string
      def self.parse_helper!(parsed_string)
        param_arr = []
        pag_arr = []
        field_arr = []

        parsed_string.each do |key, val|
          # Check for page[...] and store key in p
          p = /page\[(.*)\]/.match(key)
          unless p.nil?
            pag_arr << [p[1], val]
            next
          end

          f = /fields\[(.*)\]/.match(key)
          unless f.nil?
            field_arr << [f[1], val]
            next
          end

          param_arr << [key, val]
        end

        # Create Params, Pagination, and FieldSets objects
        params = Params.new(param_arr)
        pagination = Pagination.new(pag_arr)
        field_sets = FieldSets.new(field_arr)

        [params, pagination, field_sets]
      end
    end

    # Header parsing logic
    module ParseHeaders
      def self.parse!(env)
        h_arr = []
        env.each_key do |k|
          if k.start_with?('HTTP_') && (k != 'HTTP_VERSION')
            h_arr << [k[5..], env[k]]
          elsif k == 'CONTENT_TYPE'
            h_arr << [k, env[k]]
          end
        end
        Headers.new(h_arr)
      end
    end

    # Document Parsing Logic
    module ParseDocument
      def self.parse!(_env)
        'Parse_document called'
      end
    end
  end
end
