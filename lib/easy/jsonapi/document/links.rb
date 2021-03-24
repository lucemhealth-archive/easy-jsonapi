# frozen_string_literal: true

require 'easy/jsonapi/name_value_pair_collection'
require 'easy/jsonapi/document/links/link' # extension
require 'easy/jsonapi/utility'

module JSONAPI
  class Document
    
    # The links of a resource
    class Links < JSONAPI::NameValuePairCollection

      # @param link_arr [Array<JSONAPI::Document::Links::Link] The array
      #   of links to initialize this collection with.
      def initialize(link_arr = [])
        super(link_arr, item_type: JSONAPI::Document::Links::Link)
      end

      # Add a jsonapi member to the collection
      # @param link [JSONAPI::Document::Links:Link] The member to add
      def add(link)
        super(link, &:name)
      end
    end
  end
end

# #empyt? provided by super class
# #include provided by super class
# #add provided by super
# #each provided from super class
# #remove provided from super class
# #get provided by super class
# #keys provided by super class
# #size provided by super class
# #to_s provided from super class
