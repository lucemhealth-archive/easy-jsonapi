# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/document'

module JSONAPI
  class Document

    # The jsonapi document 'included' top level member
    class Included < JSONAPI::Collection

      def initialize(res_obj_arr = [])
        super(res_obj_arr) { |res| "#{res.type}|#{res.id}" }
      end

      def to_s
        to_return = '['
        first = true
        each do |res|
          if first
            to_return += res.to_s
            first = false
          else
            to_return += ", #{res}"
          end
        end
        to_return += ']'
      end

    end
  end
end
