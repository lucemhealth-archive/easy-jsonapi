# frozen_string_literal: true

require 'easy/jsonapi/request/query_param_collection/query_param'
require 'easy/jsonapi/utility'

module JSONAPI
  class Request
    class QueryParamCollection < JSONAPI::NameValuePairCollection
      
      # Used to create a unique Filter JSONAPI::Request::QueryParamCollection::QueryParam
      class FilterParam < QueryParam
        
        # @param filter_arr [Array<JSONAPI::Request::QueryParamCollection::FilterParam::Filter>]
        #   The array of filters included in the query string. Ex: filter[articles]=(posted_date == today)
        def initialize(filter_arr)
          super('filters', filter_arr)
        end

        # Represent each filter separated by a & value
        #   Ex: "#{filter1.to_s}&{filter2.to_s}&..."
        def to_s
          JSONAPI::Utility.to_string_collection(value, delimiter: '&')
        end

      end
    end
  end
end
