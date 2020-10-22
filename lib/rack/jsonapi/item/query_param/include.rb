# frozen_string_literal: true

module JSONAPI
  class Item
    class QueryParam
      # Used to create a unique Include QueryParam
      class Include < JSONAPI::Item::QueryParam
        
        # #name provided by super class

        # @query_param resource [String | Array<String>] A value given to include
        def initialize(resource)
          resource = resource.split('.') if resource.is_a? String
          super('include', resource)
        end
        
        # @returns [Array<String>] A an array of the resource 'path'
        def resource
          @item[:value]
        end

        # @query_param new_resource [String | Array<String>] The new resource
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
        # @query_param [Any] Any given input.
        def name=(_)
          raise 'Cannot set the name of a Include object'
        end

        # Raise a runtime error if value is attempted to be accessed
        def value
          raise 'Include objects do not have a value method, try #resource'
        end

        # Raise a runtime error if value is attempted to be reset
        # @query_param [Any] Any given input.
        def value=(_)
          raise 'Cannot set value of Include object, becausee Include does not have a value'
        end
      end
    end
  end
end
