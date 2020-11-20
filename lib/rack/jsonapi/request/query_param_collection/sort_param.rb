# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/query_param'

module JSONAPI
  class Request
    class QueryParamCollection < JSONAPI::NameValuePairCollection
      # Used to create a unique Sort JSONAPI::Request::QueryParamCollection::QueryParam
      class SortParam < QueryParam
        
        # @param res_field_arr [Array<JSONAPI::Field] The resource fields
        #   to sort the primary resources by.
        def initialize(res_field_arr)
          super('sorts', res_field_arr)
        end

        # Represent sort as query string
        def to_s
          "sort=#{JSONAPI::Utility.to_string_collection(value, delimiter: ',')}"
        end
  
      end
    end
  end
end
