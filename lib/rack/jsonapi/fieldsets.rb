# frozen_string_literal: true

module JSONAPI

  # Makes FieldSet class private
  private_constant :FieldSet

  # Contains all request field_sets
  class FieldSets
    def initialize(field_sets = [])
      @field_sets = {}
      field_sets.each do |p|
        k = to_hash_key(p[0])
        @field_sets[k] = FieldSet.new(p[0], p[1])
      end
    end

    # @param key [Symbol | String] The param key
    # @param val [String] The param value.
    # @returns [FieldSets] The field_sets object with another internal param added to it.
    def add(key, val)
      k = to_hash_key(key)
      @field_sets[k] = FieldSet.new(key, val)
    end

    # @param key [Symbol | String] The param key
    # @return [String] the value of the removed param's value
    def remove(key)
      k = to_hash_key(key)
      deleted = @field_sets.delete(k)
      deleted.val
    end

    # @param (see #remove))
    # @return val [String] The appropriate param's value
    def get(key)
      k = to_hash_key(key)
      @field_sets[k].val
    end

    # @param (see #add)
    def set(key, val)
      k = to_hash_key(key)
      @field_sets[k].val = val
    end

    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for FieldSets' internal hash.
    # @param dev_input [Symbol | String] Whatever the developer uses as a param key.
    # @!visibility private
    def to_hash_key(dev_in)
      case type
      when String
        k = dev_in.downcase.to_sym
      when Symbol
        k = dev_in.to_s.downcase.to_sym
      end
      k
    end

    # Allows the developer to treat the FieldSets class as a hash, retrieving all param keys.
    # @return [Array<String>] An array of all the param keys stored in the FieldSets object.
    def keys
      @field_sets.map(&:val)
    end

    # Models a FieldSet's key -> value relationship
    # @!visibility private
    class FieldSet
      attr_accessor :key, :val

      def initialize(key, val)
        @key = key
        @val = val
      end
    end
  end
end
