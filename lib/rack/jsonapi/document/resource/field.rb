# frozen_string_literal: true

require 'rack/jsonapi/item'

module JSONAPI
  class Document
    class Resource
      
      # Field is the name of an 
      class Field < JSONAPI::Item

        # @param name [String]  The name of the field
        # @param type [String | nil] The type of the field
        def initialize(name, type: String)
          super({ name: name, type: type })
        end

        def name
          @item[:name]
        end

        def name=(new_name)
          @item[:name] = new_name
        end

        def type
          @item[:type]
        end

        def type=(new_type)
          @item[:type] = new_type
        end

        def to_s
          "\"#{name}\" => #{type}"
        end

      end
    end
  end
end
