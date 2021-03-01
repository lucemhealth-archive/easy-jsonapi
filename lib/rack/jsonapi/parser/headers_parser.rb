# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/header_collection'

require 'rack/jsonapi/item'
require 'rack/jsonapi/header_collection/header'

require 'rack/jsonapi/exceptions/headers_exceptions'

module JSONAPI
  module Parser

    # Header parsing logic
    module HeadersParser
      
      # @param env [Hash] The rack envirornment hash
      # @return [JSONAPI::HeaderCollection] The collection of parsed header objects
      def self.parse(env)
        h_collection = JSONAPI::HeaderCollection.new
        env.each_key do |k|
          if k.start_with?('HTTP_') && (k != 'HTTP_VERSION')
            h_collection << JSONAPI::HeaderCollection::Header.new(k[5..], env[k])
          elsif k == 'CONTENT_TYPE'
            h_collection << JSONAPI::HeaderCollection::Header.new(k, env[k])
          end
        end
        h_collection
      end
    end

  end
end
