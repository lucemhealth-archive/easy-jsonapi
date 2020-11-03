# frozen_string_literal: true

require 'rack/jsonapi/document/resource/attributes'
require 'rack/jsonapi/document/resource/field'

module JSONAPI
  class Document
    class Resource < JSONAPI::Document::ResourceId
      class Attributes

        # An individual attribute in a JSON:API Attributes object
        class Attribute < JSONAPI::Document::Resource::Field

          attr_accessor :value

          def initialize(name, value, type: String)
            @value = value
            super(name, type: type)
          end

          def to_s
            "\"#{name}\": \"#{@value}\""
          end

        end
      end
    end
  end
end
