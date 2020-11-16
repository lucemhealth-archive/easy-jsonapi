# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/filter_param'

module JSONAPI
  class Request
    class QueryParamCollection < NameValuePairCollection
      class FilterParam < QueryParam
        # Represents an individual Filtering scheme for the filter query param(s) used.
        class Filter

          attr_accessor :resource_type, :filter_string

          def initialize(resource_type, filter_string)
            @resource_type = resource_type
            @filter_string = filter_string
          end

          def to_s
            "filter[#{@resource_type}]=#{@filter_string}"
          end
        end
      end
    end
  end
end
