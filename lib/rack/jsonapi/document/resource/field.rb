# frozen_string_literal: true

module JSONAPI
  class Document
    class Resource
      
      # The key-value fields that make up the attributes of a Resource
      class Field

        # @returns name [String] The name of the field
        # @returns value [String] The value of the field
        attr_accessor :name, :value
        
        # @param name [String] The name of the field
        # @param value [String | nil] The value of the field
        def initialize(name, value = nil)
          @name = name
          @value = value
        end
        
        def to_s
          "{ #{@name} => #{@value} }"
        end
      end
    end
  end
end
