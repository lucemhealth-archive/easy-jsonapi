# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/filter_param'

module JSONAPI
  class Request
    class QueryParamCollection < NameValuePairCollection
      class FilterParam < QueryParam
        # Represents an individual Filtering scheme for the filter query param(s) used.
        class Filter

          attr_reader :resource_type, :filter_string

          # @param resource_type [String] The type to filter
          # @param filter_string [String] The filter algorithm
          def initialize(resource_type, filter_string)
            @resource_type = resource_type
            @filter_string = filter_string
          end

          # Represent filter as an individual filter query param
          def to_s
            "filter[#{@resource_type}]=#{@filter_string}"
          end
        end
      end
    end
  end
end
