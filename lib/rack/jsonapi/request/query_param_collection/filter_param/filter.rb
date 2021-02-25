# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/filter_param'

module JSONAPI
  class Request
    class QueryParamCollection < NameValuePairCollection
      class FilterParam < QueryParam
        # Represents an individual Filtering scheme for the filter query param(s) used.
        class Filter

          attr_reader :resource_type, :filter

          # @param resource_type [String] The type to filter
          # @param filter [String] The filter algorithm
          def initialize(resource_type, filter)
            @resource_type = resource_type
            @filter = filter
          end

          # @return [String] The value of the filter
          def value
            @filter
          end

          # Represent filter as an individual filter query param
          def to_s
            "filter[#{@resource_type}]=#{@filter}"
          end
        end
      end
    end
  end
end
