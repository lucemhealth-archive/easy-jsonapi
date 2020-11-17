# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/document/jsonapi/jsonapi_member'

module JSONAPI
  class Document
    
    # The jsonapi top level member of a JSON:API document
    class Jsonapi < JSONAPI::NameValuePairCollection

      def initialize(jsonapi_member_arr = [])
        super(jsonapi_member_arr, item_type: JSONAPI::Document::Jsonapi::JsonapiMember)
      end

    end
  end
end
