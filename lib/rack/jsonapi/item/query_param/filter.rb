# frozen_string_literal: true

module JSONAPI
  class Item
    class QueryParam
      # Used to create a unique Filter QueryParam
      class Filter < JSONAPI::Item::QueryParam
        
        # #name provided by super class
        # #value & #value= provided by super class
        
        # @query_param value [String | Array<String>] The value of the filter parameter
        def initialize(value)
          super('filter', value)
        end

        # Raise a runtime error if name is attempted to be reset
        # @query_param [Any] Any given input.
        def name=(_)
          raise 'Cannot set the name of a Filter object'
        end
      end
    end
  end
end
