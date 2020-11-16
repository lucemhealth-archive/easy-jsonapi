# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/query_param'

module JSONAPI
  class Request
    class QueryParamCollection < JSONAPI::NameValuePairCollection
      # Used to create a unique Page JSONAPI::Request::QueryParamCollection::QueryParam
      class PageParam < QueryParam
        
        # @param offset [Integer | String] the page offset
        # @param limit [Integer | String] the # of resources returned on a given page
        def initialize(offset:, limit:)
          super('page', { offset: offset.to_i, limit: limit.to_i })
        end

        # @raise [RuntimeError] Informs user to use a different method
        def value
          raise 'PageParam does not provide a #value method, try #offset or #limit instead'
        end

        # @raise [RuntimeError] Informs user to use a different method
        def value=(_)
          raise 'PageParam does not provide a #value= method, try #offset= or #limit= instead'
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
          "page[offset]=#{offset}&page[limit]=#{limit}"
        end

      end
    end
  end
end
