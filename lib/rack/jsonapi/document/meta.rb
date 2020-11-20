# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/document/meta/meta_member' # extension

module JSONAPI
  class Document
    
    # The meta of a resource
    class Meta < JSONAPI::NameValuePairCollection

      def initialize(meta_arr = [])
        meta_arr = [meta_arr] unless meta_arr.is_a? Array
        super(meta_arr, item_type: JSONAPI::Document::Meta::MetaMember)
      end
    end
  end
end
