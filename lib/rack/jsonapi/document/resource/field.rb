# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/document/resource_id'

module JSONAPI
  class Document
    class Resource < JSONAPI::Document::ResourceId
      
      # Field is the name of an 
      class Field < JSONAPI::Item

        # @param name [String]  The name of the field
        # @param type [String | nil] The type of the field
        def initialize(name, type: String)
          super({ name: name.to_s, type: type })
        end

        def name
          @item[:name]
        end

        def name=(new_name)
          @item[:name] = new_name.to_s
        end

        def type
          @item[:type]
        end

        def type=(new_type)
          @item[:type] = new_type
        end

        def to_s
          name.to_s
        end

        private :method_missing, :item, :item=

      end
    end
  end
end
