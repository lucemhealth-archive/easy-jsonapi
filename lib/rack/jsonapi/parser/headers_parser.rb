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
        check_content_type(env)

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

      def self.check_content_type(env)
        no_content_type_error = JSONAPI::Exceptions::HeadersExceptions.content_type_not_included_or_is_jsonapi?(env['CONTENT_TYPE'])
        msg = 'Attempting to parse headers while including a non-jsonapi compliant Content-Type'
        invalid_hdr_class = JSONAPI::Exceptions::HeadersExceptions::InvalidHeader
        raise(invalid_hdr_class.new(400), msg) unless no_content_type_error
      end

      private_class_method :check_content_type
    end

  end
end
