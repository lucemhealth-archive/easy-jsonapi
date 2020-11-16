# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/utility'

module JSONAPI
  class Request
    class QueryParamCollection < NameValuePairCollection
      class FieldsParam < QueryParam
        # Collection of fields related to specific resource objects
        class Fieldset

          attr_accessor :resource_type, :resource_fields

          # @param res_field_arr [Array<JSONAPI::Document::Resource::Field>]
          #   A fieldset is a collection of Resource Fields
          def initialize(resource_type, res_field_arr = [])
            @resource_type = resource_type
            @resource_fields = res_field_arr
          end

          # Represention of Fieldset as a string where fields
          #   are comma separated strings
          def to_s
            pre_string = "fields[#{@resource_type}]="
            JSONAPI::Utility.to_string_collection(@resource_fields, delimiter: ',', pre_string: pre_string)
          end

        end
      end
    end
  end
end
