# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'

module JSONAPI
  class Document
    
    # The links of a resource
    class Links < JSONAPI::NameValuePairCollection

      def initialize(link_arr = [])
        super(link_arr, JSONAPI::Document::Links::Link)
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

    end
  end
end
