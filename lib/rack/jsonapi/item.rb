# frozen_string_literal: true

module JSONAPI

  # Models a Item's key -> value relationship
  class Item

    # @returns the value of an Item
    attr_accessor :item
    
    # Takes a hash and dynamically creates instance variables using the hash keys
    #   Ex: obj == { :name => 'fields', :value => {'articles' => 'title,body,author', 'people' => 'name' }}
    def initialize(obj)
      @item = obj
      # obj.each do |key, value|
      #   instance_variable_set("@#{key}", value) # @articles, @people
      # end
    end

    # Only used if implementing Item directly.
    #   dynamically creates accessor methods for instance variables
    #   created in the initialize
    def method_missing(method_name, *args, &block)
      return unless is_a? JSONAPI::Item
      if should_update_var?(method_name)
        @item[method_name[..-2].to_sym] = args[0]
      elsif should_get_var?(method_name)
        @item[method_name]
      else
        super
      end
    end

    # Needed when using #method_missing
    def respond_to_missing?(method_name, *)
      instance_variables.include?("@#{method_name}".to_sym) || super
    end

    def to_s
      tr = '{ '
      first = true
      @item.each do |k, v|
        if first
          first = false
          tr += "#{k} => '#{v}', "
        else
          tr += "#{k} => '#{v}'"
        end
      end
      tr += ' }'
    end

    private
    
    # Checks to see if the method name has a '=' at the end and if the 
    #   prefix before the '=' has the same name as an existing instance
    #   variable.
    # @query_param (see #method_missing)
    def should_update_var?(method_name)
      method_name.to_s[-1] == '=' && @item[method_name[..-2].to_sym].nil? == false
    end
    
    # Checks to see if the method has the same name as an existing instance
    #   variable
    # @query_param (see #method_missing)
    def should_get_var?(method_name)
      @item[method_name].nil? == false
    end
  end
end
