# frozen_string_literal: true

module JSONAPI

  # Models a Item's key -> value relationship
  class Item

    # @return the value of an Item
    attr_accessor :item
    
    # Able to take a hash and dynamically create instance variables using the hash keys
    #   Ex: obj == { :name => 'fields', :value => {'articles' => 'title,body,author', 'people' => 'name' }}
    # @param obj [Object] Can be anything, but if a hash is provided, dynamic instance variable can be created
    #   upon trying to access them.
    def initialize(obj)
      if obj.is_a? Hash
        ensure_keys_are_sym(obj)
      end
      @item = obj
    end

    # A special to_string method if @item is a hash.
    def to_s
      return @item.to_s unless @item.is_a? Hash
      tr = '{ '
      first = true
      @item.each do |k, v|
        if first
          first = false
          tr += "\"#{k}\": \"#{v}\", "
        else
          tr += "\"#{k}\": \"#{v}\""
        end
      end
      tr += ' }'
    end

    # Represent item as a hash
    def to_h
      @item.to_h
    end

    private

    # Only used if implementing Item directly.
    #   dynamically creates accessor methods for instance variables
    #   created in the initialize
    def method_missing(method_name, *args, &block)
      return super unless is_a? JSONAPI::Item
      return super unless @item.is_a? Hash
      if should_update_var?(method_name)
        @item[method_name[..-2].to_sym] = args[0]
      elsif should_get_var?(method_name)
        @item[method_name]
      else
        super
      end
    end

    # Needed when using #method_missing
    def respond_to_missing?(method_name, *args)
      instance_variables.include?("@#{method_name}".to_sym) || super
    end

    # Ensures that hash keys are symbol (and not String) when passing a hash to item.
    # @param obj [Object]  A hash that can represent an item.
    def ensure_keys_are_sym(obj)
      obj.each_key do |k|
        raise "All keys must be Symbols. '#{k}' was #{k.class}" unless k.is_a? Symbol
      end
    end
    
    # Checks to see if the method name has a '=' at the end and if the 
    #   prefix before the '=' has the same name as an existing instance
    #   variable.
    # @param (see #method_missing)
    def should_update_var?(method_name)
      method_name.to_s[-1] == '=' && @item[method_name[..-2].to_sym].nil? == false
    end
    
    # Checks to see if the method has the same name as an existing instance
    #   variable
    # @param (see #method_missing)
    def should_get_var?(method_name)
      @item[method_name].nil? == false
    end
  end
end
