# frozen_string_literal: true

require 'rack/jsonapi/field'
require 'rack/jsonapi/document/resource/attributes'

module JSONAPI
  class Document
    class Resource
      class Attributes < JSONAPI::NameValuePairCollection

        # An individual attribute in a JSON:API Attributes object
        class Attribute < JSONAPI::Field

          attr_accessor :value

          def initialize(name, value, type: String)
            @value = value
            super(name, type: type)
          end

          # @raise RuntimeError An attribute name is not updatable.
          def name=(_)
            raise 'Cannot change the name of an Attribute'
          end

          # JSON key - value notation
          def to_s
            "\"#{name}\": \"#{@value}\""
          end

        end
      end
    end
  end
end
