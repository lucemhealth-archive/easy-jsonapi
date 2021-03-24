# frozen_string_literal: true

require 'easy/jsonapi/name_value_pair_collection'
require 'easy/jsonapi/document/error/error_member' # extension
require 'easy/jsonapi/utility'

module JSONAPI
  class Document
    # An individual errors member in a jsonapi's document top level 'errors' member array
    class Error < JSONAPI::NameValuePairCollection

      # @param err_members [Array<JSONAPI::Document::Error::ErrorMember>]
      #   The error members that belong to this specific error.
      def initialize(err_members = [])
        super(err_members, item_type: JSONAPI::Document::Error::ErrorMember)
      end

      # #empyt? provided by super
      # #include provided by super
      
      # Add a error to the collection using it's name
      # @param error_mem [JSONAPI::Document::Error::ErrorMember]
      def add(error_mem)
        super(error_mem, &:name)
      end

      # Another way to call add
      # @param (see #add)
      def <<(error_mem)
        super(error_mem, &:name)
      end
      
      # #<< provided by super, but calls overriden #add
      # #each provided from super
      # #remove provided from super
      # #get provided by super
      # #keys provided by super
      # #size provided by super
      # #to_s provided by super

      # Represent an Error as a hash
      def to_h
        JSONAPI::Utility.to_h_collection(self)
      end

    end
  end
end
