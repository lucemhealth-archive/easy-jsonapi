# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/document/jsonapi/jsonapi_member' # extension

module JSONAPI
  class Document
    
    # The jsonapi top level member of a JSON:API document
    class Jsonapi < JSONAPI::NameValuePairCollection

      # @param jsonapi_member_arr [Array<JSONAPI::Document::Jsonapi::JsonapiMember] The collection
      #   of members to intialize this collection with.
      def initialize(jsonapi_member_arr = [])
        super(jsonapi_member_arr, item_type: JSONAPI::Document::Jsonapi::JsonapiMember)
      end

      # Add a jsonapi member to the collection
      # @param jsonapi_member [JSONAPI::Document::Jsonapi::JsonapiMember] The member to add
      def add(jsonapi_member)
        super(jsonapi_member, &:name)
      end

    end
  end
end
