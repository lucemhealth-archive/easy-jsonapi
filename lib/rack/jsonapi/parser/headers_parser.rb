# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/header_collection'

require 'rack/jsonapi/item'
require 'rack/jsonapi/header_collection/header'

require 'rack/jsonapi/exceptions'
require 'rack/jsonapi/exceptions/headers_exceptions'

module JSONAPI
  module Parser

    # Header parsing logic
    module HeadersParser
      
      def self.parse!(env)
        JSONAPI::Exceptions::HeadersExceptions.check_compliance!(env)

        h_arr = []
        env.each_key do |k|
          if k.start_with?('HTTP_') && (k != 'HTTP_VERSION')
            h_arr << JSONAPI::HeaderCollection::Header.new(k[5..], env[k])
          elsif k == 'CONTENT_TYPE'
            h_arr << JSONAPI::HeaderCollection::Header.new(k, env[k])
          end
        end
        JSONAPI::HeaderCollection.new(h_arr)
      end

    end

  end
end
