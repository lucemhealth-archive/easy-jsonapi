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
      # @param [JSONAPI::Item::Param] The param or param subclass to add.
      def add(param)
        return unless param.is_a? JSONAPI::Item::Param
        # add the param type unless it is already included
        p_name = get_simple_param_name(param)
        @param_types << p_name unless p_name == 'params' || @param_types.include?(p_name)
        super(param, &:name)
      end

      # Constructs a simplified Param class name to match with method_name
      #   in #missing_method and #add
      def get_simple_param_name(param)
        i = param.class.name.rindex('::')
        raise "i is nil?" if i.nil?
        name = param.class.name[(i + 2)..]
        name.downcase!
        "#{name}s"
      end

      # Another way to add a param
      # @oaram (see #add)
      def <<(param)
        add(param)
      end

      # #each provided from super class
      # #remove provided from super class
      # #get provided by super class
      # #keys provided by super class
      # #size provided by super class

      def method_missing(method_name, *args, &block)
        super unless @param_types.include?(method_name.to_s)
        new_arr = @collection.filter { |_, p| get_simple_param_name(p) == method_name }
        JSONAPI::Collection::ParamCollection.new(new_arr)
      end

      def respond_to_missing?(method_name, *)
        @param_types.include?(method_name) || super
      end
    end
  end  
end
