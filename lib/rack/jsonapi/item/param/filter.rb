# frozen_string_literal: true

module JSONAPI
  class Item
    class Param
      # Used to create a unique Filter Param
      class Filter < JSONAPI::Item::Param
        
        # #name provided by super class
        # #value & #value= provided by super class
        
        # @param value [String | Array<String>] The value of the filter parameter
        def initialize(value)
          super('filter', value)
        end

        # Raise a runtime error if name is attempted to be reset
        # @param [Any] Any given input.
        def name=(_)
          raise 'Cannot set the name of a Filter object'
        end
      end
    end
  end
end
