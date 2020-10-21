# frozen_string_literal: true

require 'rack/jsonapi/document/links'
require 'rack/jsonapi/item'

module JSONAPI
  class Document
    class Links

      # An individual attribute in a JSON:API Links object
      class Link < JSONAPI::Item
      
        # @param name The name of the parameter
        # @param value The value of the parameter
        def initialize(name, value)
          super({ name: name.to_s, value: value })
        end

        # @return [String] The name of the header
        def name
          @item[:name]
        end

        # @param new_name [String | Symbol] The new header name
        def name=(new_name)
          @item[:name] = new_name.to_s
        end

        # @return [String] The value of the header
        def value
          @item[:value]
        end

        # @param new_value [String | Symbol] The header value
        def value=(new_value)
          @item[:value] = new_value
        end

        # Represents a parameter as a string
        def to_s
          "{ '#{name}' => '#{value}' }"
        end

        # prevent Param and Subclasses from accessing Item's #method_missing
        private :method_missing
      end
    end
  end
end
