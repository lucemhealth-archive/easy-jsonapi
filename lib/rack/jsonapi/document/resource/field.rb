# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/document/resource_id'

module JSONAPI
  class Document
    class Resource
      
      # Field is the name of an 
      class Field < JSONAPI::Item

        # @param name [String]  The name of the field
        # @param type [String | nil] The type of the field
        def initialize(name, type: String)
          super({ name: name.to_s, type: type })
        end

        # @return [String] The Field's name
        def name
          @item[:name]
        end

        # @param new_name [String | Symbol] The new name of the resource field
        def name=(new_name)
          @item[:name] = new_name.to_s
        end

        # @return [Object] The type of the field
        def type
          @item[:type]
        end

        # @param new_type [Object] The new type of field.
        def type=(new_type)
          @item[:type] = new_type
        end

        # @return [String] The name of the field.
        def to_s
          name
        end

        private :method_missing, :item, :item=

      end
    end
  end
end
