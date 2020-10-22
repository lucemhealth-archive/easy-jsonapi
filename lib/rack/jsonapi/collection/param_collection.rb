# frozen_string_literal: true

module JSONAPI
  class Collection
    
    # param_collection # { include: Include, sort: Sort, filter: Filter } 
    class ParamCollection < JSONAPI::Collection
      
      def initialize(param_arr = [])
        @param_types = []
        super(param_arr, &:name)
      end

      # #empyt? provided by super class
      # #include provided by super class
      # @query_param [JSONAPI::Item::QueryParam] The query_param or query_param subclass to add.
      def add(query_param)
        return unless query_param.is_a? JSONAPI::Item::QueryParam
        # add the query_param type unless it is already included
        p_name = get_simple_param_name(query_param)
        @param_types << p_name unless p_name == 'params' || @param_types.include?(p_name)
        super(query_param, &:name)
      end

      # Constructs a simplified QueryParam class name to match with method_name
      #   in #missing_method and #add
      def get_simple_param_name(query_param)
        i = query_param.class.name.rindex('::')
        raise "i is nil?" if i.nil?
        name = query_param.class.name[(i + 2)..]
        name.downcase!
        "#{name}s"
      end

      # Another way to add a query_param
      # @oaram (see #add)
      def <<(query_param)
        add(query_param)
      end

      # #each provided from super class
      # #remove provided from super class
      
      # def get(resource_name)
      #   super(resource_name)
      # end

      # #keys provided by super class
      # #size provided by super class

      def method_missing(method_name, *args, &block)
        super unless @param_types.include?(method_name.to_s)
        selected_collection = JSONAPI::Collection::ParamCollection.new
        @collection.each_value do |p|
          if get_simple_param_name(p) == method_name.to_s
            selected_collection.add(p)
          end
        end

        selected_collection
      end

      def respond_to_missing?(method_name, *)
        @param_types.include?(method_name) || super
      end
    end
  end  
end
