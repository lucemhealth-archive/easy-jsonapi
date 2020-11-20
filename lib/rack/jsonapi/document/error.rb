# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/document/error/error_member' # extension
require 'rack/jsonapi/utility'

module JSONAPI
  class Document
    # An individual errors member in a jsonapi's document top level 'errors' member array
    class Error < JSONAPI::NameValuePairCollection

      # @param err_members [Array<JSONAPI::Document::Error::ErrorMember>]
      #   The error members that belong to this specific error.
      def initialize(err_members = [])
        @error_names = []
        super(err_members, item_type: JSONAPI::Document::Error::ErrorMember)
      end

      # #empyt? provided by super class
      # #include provided by super class
      
      # @param query_param [JSONAPI::Request::QueryParamCollection::QueryParam] The query_param or query_param subclass to add.
      def add(query_param)
        p_name = query_param.name
        @error_names << p_name unless @error_names.include?(p_name)
        super(query_param)
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

      private

      # Gets the QueryParam class whose name matches the method_name called
      # @param method_name [Symbol] The name of the method called
      # @param args If any arguments were passed to the method called
      # @param block If a block was passed to the method called
      def method_missing(method_name, *args, &block)
        super unless @error_names.include?(method_name.to_s)
        get(method_name).value
      end
  
      # Whether or not method missing should be called.
      def respond_to_missing?(method_name, *)
        @error_names.include?(method_name) || super
      end
      
    end
  end
end
