# frozen_string_literal: true

require 'rack/jsonapi/field'
require 'rack/jsonapi/document/resource/attributes'
require 'rack/jsonapi/name_value_pair'

module JSONAPI
  class Document
    class Resource
      class Attributes < JSONAPI::NameValuePairCollection

        # An individual attribute in a JSON:API Attributes object
        class Attribute < JSONAPI::NameValuePair

          attr_reader :field

          # @param name [String] The name of an attribute
          # @param value [String] The value of an attribute
          # @param type [Any] The type of an attribute value
          def initialize(name, value, type: String)
            @field = JSONAPI::Field.new(name, type: type)
            super(name, value)
          end

        end
      end
    end
  end
end
