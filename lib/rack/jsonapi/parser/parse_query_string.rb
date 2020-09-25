# frozen_string_literal: true

require 'rack/jsonapi/params'
require 'rack/jsonapi/pagination'
require 'rack/jsonapi/field_sets'

module JSONAPI
  module Parser
    
    # Query String Parsing Logic
    module ParseQueryString
      
      # @param query_string [String] The query string of the request url
      # @return [JSONAPI::Params, JSONAPI::Pagination, JSONAPI::FieldSets]
      def self.parse!(query_string)
        parsed_string = {}
        arr = query_string.split(/&|=/)
        
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
  end
end
    