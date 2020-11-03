# frozen_string_literal: true

module JSONAPI
  class Request
    class QueryParamCollection
      class QueryParam
        # Used to create a unique Page JSONAPI::Request::QueryParamCollection::QueryParam
        class Page < QueryParam
          
          # @param offset [Integer | String] the page offset
          # @param limit [Integer | String] the # of resources returned on a given page
          def initialize(offset, limit)
            super('page', { offset: offset.to_i, limit: limit.to_i })
          end
    
          # #name provided by super class
    
          # Raise a runtime error if name is attempted to be reset
          # @param _ [Any]  given input.
          def name=(_)
            raise 'Cannot set the name of a Page object'
          end
    
          # Raise a runtime error if value is attempted to be accessed
          def value
            raise 'Page objects do not have a value method, try #offset or #limit'
          end
    
          # Raise a runtime error if value is attempted to be reset
          # @param _ [Any]  given input.
          def value=(_)
            raise 'Cannot set value of Page object, becausee Page does not have a value'
          end
    
          # @return [Integer] The page offset
          def offset
            @item[:value][:offset]
          end
    
          # @param new_offset [Integer | String] The new page offset number
          def offset=(new_offset)
            @item[:value][:offset] = new_offset.to_i
          end
    
          # @return [Integer] The # of resources returned on a given page
          def limit
            @item[:value][:limit]
          end
    
          # @param new_limit [Integer] The new page limit number
          def limit=(new_limit)
            @item[:value][:limit] = new_limit.to_i
          end
    
          # Represents the Page class in a string format
          def to_s
            "{ \"page\": { \"offset\": \"#{offset}\", \"limit\": \"#{limit}\" } }"
          end
  
        end
      end
    end
  end
end
