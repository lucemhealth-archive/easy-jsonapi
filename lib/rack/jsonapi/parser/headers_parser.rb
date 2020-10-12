# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/collection/header_collection'

require 'rack/jsonapi/item'
require 'rack/jsonapi/item/header'

module JSONAPI
  module Parser

    # Header parsing logic
    module HeadersParser
      
      def self.parse!(env)
        h_arr = []
        env.each_key do |k|
          if k.start_with?('HTTP_') && (k != 'HTTP_VERSION')
            h_arr << JSONAPI::Item::Header.new(k[5..], env[k])
          elsif k == 'CONTENT_TYPE'
            h_arr << JSONAPI::Item::Header.new(k, env[k])
          end
        end
        JSONAPI::Collection::HeaderCollection.new(h_arr)
      end

    end

  end
end
