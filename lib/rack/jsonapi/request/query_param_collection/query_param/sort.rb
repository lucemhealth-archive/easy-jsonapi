# frozen_string_literal: true

module JSONAPI
  class Request
    class QueryParamCollection
      class QueryParam
        # Used to create a unique Sort JSONAPI::Request::QueryParamCollection::QueryParam
        class Sort < QueryParam
          
          # #name provided by super class
          # #value and #value= provided by super class
          
          # @query_param value [String | Array<String>] The value of the sort parameter
          def initialize(value)
            super('sort', value)
          end
    
          # Raise a runtime error if name is attempted to be reset
          # @query_param [Any] Any given input.
          def name=(_)
            raise 'Cannot set the name of a Sort object'
          end
          
        end
      end
    end
  end
end
