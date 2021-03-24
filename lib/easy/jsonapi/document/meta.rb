# frozen_string_literal: true

require 'easy/jsonapi/name_value_pair_collection'
require 'easy/jsonapi/document/meta/meta_member' # extension

module JSONAPI
  class Document
    
    # The meta of a resource
    class Meta < JSONAPI::NameValuePairCollection

      # @param meta_arr [Array<JSONAPI::Document::Meta::MetaMember] The 
      #   array of meta members to initialize the collection with
      def initialize(meta_arr = [])
        meta_arr = [meta_arr] unless meta_arr.is_a? Array
        super(meta_arr, item_type: JSONAPI::Document::Meta::MetaMember)
      end

      # Add a jsonapi member to the collection
      # @param meta_member [JSONAPI::Document::Meta::MetaMember] The member to add
      def add(meta_member)
        super(meta_member, &:name)
      end
    end
  end
end
