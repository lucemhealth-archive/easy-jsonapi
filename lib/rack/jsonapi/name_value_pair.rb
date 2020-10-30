# frozen_string_literal: true

require 'rack/jsonapi/item'

module JSONAPI
  # A generic name->value query pair
  class NameValuePair < JSONAPI::Item
    
    # @param name The name of the pair
    # @param value The value of the pair
    def initialize(name, value)
      super({ name: name.to_s, value: value })
    end

    # @return [String] The name of the header
    def name
      @item[:name]
    end

    # @param new_name [String | Symbol]  The new header name
    def name=(new_name)
      @item[:name] = new_name.to_s
    end

    # @return [String] The value of the header
    def value
      @item[:value]
    end

    # @param new_value [String | Symbol]  The header value
    def value=(new_value)
      @item[:value] = new_value
    end

    # Represents a pair as a string
    def to_s
      v = value
      case v
      when Array
        val_str = '['
        first = true
        v.each do |val|
          if first
            val_str += "\"#{val}\""
            first = false
          else
            val_str += ", \"#{val}\""
          end
        end
        val_str += ']'
      when String
        val_str = "\"#{v}\""
      else
        raise 'NameValuePair to_s was not array or string'
      end
      "\"#{name}\": #{val_str}"
    end

    # prevent users and sublcasses from accessing Parent's #method_missing
    private :method_missing
  end
end
