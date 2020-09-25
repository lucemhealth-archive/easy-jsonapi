# frozen_string_literal: true

require 'rack/jsonapi/headers'

module JSONAPI
  module Parser

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

  end
end
