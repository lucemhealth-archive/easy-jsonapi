# frozen_string_literal: true

module JSONAPI
  class Item
    # A generic name->value query parameter
    class Param < JSONAPI::Item
      
      # @param name The name of the parameter
      # @param value The value of the parameter
      def initialize(name, value)
        value = value.split(',') if value.is_a? String
        super({ name: name.to_s, value: value })
      end

      # Retrieve the name of the Param
      def name
        @item[:name]
      end

      # Update the parameter name
      # @param new_name [String | Symbol] The new name of the Param
      def name=(new_name)
        @item[:name] = new_name.to_s
      end

      # Retireve the value of a Param
      def value
        @item[:value]
      end

      # Update the param value, turning value into an array if it was given as a string
      # @param new_val [String, Array<String>] The new value of the Parameter
      def value=(new_val)
        new_val = new_val.split(',') if new_val.is_a? String
        @item[:value] = new_val
      end
      
      # Represents a parameter as a string
      def to_s
        str_val = @item[:value].join(',') if @item[:value].is_a? Array
        "{ '#{name}' => '#{str_val}' }"
      end

      # prevent Param and Subclasses from accessing Item's #method_missing and @item
      private :method_missing, :item, :item=
    end
  end
end
