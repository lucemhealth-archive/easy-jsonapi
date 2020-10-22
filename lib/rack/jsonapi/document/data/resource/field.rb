# frozen_string_literal: true

module JSONAPI
  class Document
    module Data
      class Resource
        
        # The key-value fields that make up the attributes of a Resource
        class Field
  
          # @returns name [String] The name of the field
          # @returns value [String] The value of the field
          attr_accessor :name, :value
          
          # @query_param name [String] The name of the field
          # @query_param value [String | nil] The value of the field
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
end
