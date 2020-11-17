# frozen_string_literal: true

require 'rack/jsonapi/item'

module JSONAPI
  # Field is the name of key value pair
  class Field < JSONAPI::Item

    # @param name [String]  The name of the field
    # @param type [String | nil] The type of the field
    def initialize(name, type: String)
      super({ name: name.to_s, type: type })
    end

    # @return [String] The Field's name
    def name
      @item[:name]
    end

    # @raise RunTimeError You shoulddn't be able to update the name of a
    #   Resource::Field
    def name=(_)
      raise 'Cannot change the name of a Resource::Field'
    end

    # @return [Object] The type of the field
    def type
      @item[:type]
    end

    # @param new_type [Object] The new type of field.
    def type=(new_type)
      @item[:type] = new_type
    end

    # @return [String] The name of the field.
    def to_s
      name
    end

    private :method_missing, :item, :item=
  end
end
