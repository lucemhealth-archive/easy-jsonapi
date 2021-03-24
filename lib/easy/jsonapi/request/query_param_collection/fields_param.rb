# frozen_string_literal: true

require 'easy/jsonapi/request/query_param_collection/query_param'

module JSONAPI
  class Request
    class QueryParamCollection < JSONAPI::NameValuePairCollection
      # Used to create a unique Fieldset JSONAPI::Request::QueryParamCollection::QueryParam
      class FieldsParam < QueryParam
        
        # @param fieldset_arr [Array<JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset>]
        #   The array of fieldsets found in the query string. Ex: fields[resource]=res_field1,res_field2
        def initialize(fieldset_arr)
          super('fields', fieldset_arr)
        end

        # Alias to parent #value method
        # @return [Array<JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset>]
        def fieldsets
          value
        end

        # @return The the query string representation of the included fieldsets
        #   ex: "#{fieldset1.to_s}&{fieldset2.to_s}&..."
        def to_s
          JSONAPI::Utility.to_string_collection(value, delimiter: '&')
        end
  
      end
    end
  end
end
