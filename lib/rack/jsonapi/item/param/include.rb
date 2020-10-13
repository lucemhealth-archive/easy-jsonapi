# frozen_string_literal: true

module JSONAPI
  class Item
    class Param
      # Used to create a unique Include Param
      class Include < JSONAPI::Item::Param
        
        # #name provided by super class

        # @param resource [String | Array<String>] A value given to include
        def initialize(resource)
          resource = resource.split('.') if resource.is_a? String
          super('include', resource)
        end
        
        # @returns [Array<String>] A an array of the resource 'path'
        def resource
          @item[:value]
        end

        # @param new_resource [String | Array<String>] The new resource
        def resource=(new_resource)
          new_resource = new_resource.split('.') if new_resource.is_a? String
          @item[:value] = new_resource
        end

        # Represents a Include object as a string
        def to_s
          str_resource = @item[:value].join('.') if @item[:value].is_a? Array
          "{ 'include' => '#{str_resource}' }"
        end

        # Raise a runtime error if name is attempted to be reset
        # @param [Any] Any given input.
        def name=(_)
          raise 'Cannot set the name of a Include object'
        end

        # Raise a runtime error if value is attempted to be accessed
        def value
          raise 'Include objects do not have a value method, try #resource'
        end

        # Raise a runtime error if value is attempted to be reset
        # @param [Any] Any given input.
        def value=(_)
          raise 'Cannot set value of Include object, becausee Include does not have a value'
        end
      end
    end
  end
end
