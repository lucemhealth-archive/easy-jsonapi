# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/exceptions/naming_exceptions'

module JSONAPI
  class Request
    # query_param_collection # { include: Include, sort: Sort, filter: Filter } 
    class QueryParamCollection < JSONAPI::NameValuePairCollection
      
      def initialize(param_arr = [])
        @param_types = []
        super(param_arr, JSONAPI::Request::QueryParamCollection::QueryParam)
      end
  
      # #empyt? provided by super class
      # #include provided by super class
      # @query_param [JSONAPI::Request::QueryParamCollection::QueryParam] The query_param or query_param subclass to add.
      def add(query_param)
        raise 'Must add a valid QueryParam object' unless query_param.is_a? JSONAPI::Request::QueryParamCollection::QueryParam

        p_name = get_simple_param_name(query_param)
        @param_types << p_name unless p_name == 'params' || @param_types.include?(p_name)
        super(query_param, &:name)
      end
  
      # #<< provided by super, but calls overriden #add
      # #each provided from super
      # #remove provided from super
      # #get provided by super
      # #keys provided by super
      # #size provided by super
  
      def method_missing(method_name, *args, &block)
        super unless @param_types.include?(method_name.to_s)
        selected_collection = JSONAPI::Request::QueryParamCollection.new
        each do |p|
          if get_simple_param_name(p) == method_name.to_s
            selected_collection.add(p)
          end
        end
  
        selected_collection
      end
  
      def respond_to_missing?(method_name, *)
        @param_types.include?(method_name) || super
      end
  
      private
  
      # Constructs a simplified JSONAPI::Request::QueryParamCollection::QueryParam class name to match with method_name
      #   in #missing_method and #add
      def get_simple_param_name(query_param)
        i = query_param.class.name.rindex('::')
        raise "i is nil?" if i.nil?
        name = query_param.class.name[(i + 2)..]
        name.downcase!
        "#{name}s"
      end
    end
  end
end
