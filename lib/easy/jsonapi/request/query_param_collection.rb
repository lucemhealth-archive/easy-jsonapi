# frozen_string_literal: true

require 'easy/jsonapi/name_value_pair_collection'
require 'easy/jsonapi/utility'

module JSONAPI
  class Request
    # A collection of QueryParam objects 
    class QueryParamCollection < JSONAPI::NameValuePairCollection

      # The special query params defined by the JSON:API specification
      SPECIAL_QUERY_PARAMS = %i[sorts filters fields page includes].freeze

      # @param param_arr [Array<JSONAPI::Request::QueryParamCollection::QueryParam] The
      #   query params to initialize the collection with
      def initialize(param_arr = [])
        super(param_arr, item_type: JSONAPI::Request::QueryParamCollection::QueryParam)
      end
  
      # #empyt? provided by super class
      # #include provided by super class
      
      # Add a QueryParameter to the collection. (CASE-SENSITIVE)
      # @param param [JSONAPI::Request::QueryParamCollection::QueryParam] The param to add
      def add(param)
        super(param, &:name)
      end

      # #<< provided by super, but calls overriden #add
      # #each provided from super
      # #remove provided from super
      # #get provided by super
      # #keys provided by super
      # #size provided by super

      # Represent query param collection like the query_param string
      def to_s
        JSONAPI::Utility.to_string_collection(self, delimiter: '&')
      end

      private

      # Gets the QueryParam object whose name matches the method_name called
      # @param method_name [Symbol] The name of the method called
      # @param args If any arguments were passed to the method called
      # @param block If a block was passed to the method called
      def method_missing(method_name, *args, &block)
        included = include?(method_name)
        super unless included || SPECIAL_QUERY_PARAMS.include?(method_name)
        if included
          return get(method_name)
        end
        nil
      end

      # Whether or not method missing should be called.
      def respond_to_missing?(method_name, *)
        include?(method_name) || super
      end
    end
  end
end
