# frozen_string_literal: true

module JSONAPI
  class Item
    # A generic name->value query parameter
    class QueryParam < JSONAPI::Item
      
      # @query_param name The name of the parameter
      # @query_param value The value of the parameter
      def initialize(name, value)
        value = value.split(',') if value.is_a? String
        super({ name: name.to_s, value: value })
      end

      # Retrieve the name of the QueryParam
      def name
        @item[:name]
      end

      # Update the parameter name
      # @query_param new_name [String | Symbol] The new name of the QueryParam
      def name=(new_name)
        @item[:name] = new_name.to_s
      end

      # Retireve the value of a QueryParam
      def value
        @item[:value]
      end

      # Update the query_param value, turning value into an array if it was given as a string
      # @query_param new_val [String, Array<String>] The new value of the Parameter
      def value=(new_val)
        new_val = new_val.split(',') if new_val.is_a? String
        @item[:value] = new_val
      end
      
      # Represents a parameter as a string
      def to_s
        str_val = @item[:value].join(',') if @item[:value].is_a? Array
        "{ '#{name}' => '#{str_val}' }"
      end

      # prevent QueryParam and Subclasses from accessing Item's #method_missing and @item
      private :method_missing, :item, :item=
    end
  end
end
