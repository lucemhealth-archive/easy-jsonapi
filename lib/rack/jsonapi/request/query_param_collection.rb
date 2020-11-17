# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/utility'

module JSONAPI
  class Request
    # A collection of QueryParam objects 
    class QueryParamCollection < JSONAPI::NameValuePairCollection

      def initialize(param_arr = [])
        @param_names = []
        super(param_arr, item_type: JSONAPI::Request::QueryParamCollection::QueryParam)
      end
  
      # #empyt? provided by super class
      # #include provided by super class
      
      # @param query_param [JSONAPI::Request::QueryParamCollection::QueryParam] The query_param or query_param subclass to add.
      def add(query_param)
        p_name = query_param.name
        @param_names << p_name unless @param_names.include?(p_name)
        super(query_param)
      end
  
      # #<< provided by super, but calls overriden #add
      # #each provided from super
      # #remove provided from super
      # #get provided by super
      # #keys provided by super
      # #size provided by super

      def to_s
        JSONAPI::Utility.to_string_collection(self, delimiter: '&')
      end
  
      # Gets the QueryParam class whose name matches the method_name called
      # @param method_name [Symbol] The name of the method called
      # @param args If any arguments were passed to the method called
      # @param block If a block was passed to the method called
      def method_missing(method_name, *args, &block)
        super unless @param_names.include?(method_name.to_s)
        get(method_name)
      end
  
      # Whether or not method missing should be called.
      # TODO: look into why this works lol
      def respond_to_missing?(method_name, *)
        @param_names.include?(method_name) || super
      end

    end
  end
end
