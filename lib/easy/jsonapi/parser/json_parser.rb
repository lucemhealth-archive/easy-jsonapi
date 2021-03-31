# frozen_string_literal: true

require 'oj'
require 'easy/jsonapi/exceptions/json_parse_error'

module JSONAPI
  module Parser
    # A wrapper class for OJ parser
    module JSONParser

      # Parse JSON string into a ruby hash
      # @param document [String] The JSON string to parse
      # @raise [JSONAPI::Exceptions::JSONParseError]
      def self.parse(document, symbol_keys: true)
        Oj.load(document, symbol_keys: symbol_keys)
        
      rescue Oj::ParseError => e
        raise JSONAPI::Exceptions::JSONParseError, e.message
      end

      # Convert ruby hash into JSON
      # @param ruby_hash [Hash] THe hash to convert into JSON
      def self.dump(ruby_hash)
        Oj.dump(ruby_hash, mode: :compat)
      end

    end
  end
end
