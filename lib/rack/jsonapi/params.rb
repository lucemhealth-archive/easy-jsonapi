# frozen_string_literal: true

module JSONAPI

  # Makes Param class private
  # private_constant :Param

  # Contains all request or response params
  class Params
    def initialize(params = [])
      @params = {}
      params.each do |p|
        k = to_hash_key(p[0])
        @params[k] = Param.new(p[0], p[1])
      end
    end

    # @param key [Symbol | String] The param key
    # @param val [String] The param value.
    # @returns [Params] The params object with another internal param added to it.
    def add(key, val)
      k = to_hash_key(key)
      @params[k] = Param.new(key, val)
    end

    # @param key [Symbol | String] The param key
    # @return [String] the value of the removed param's value
    def remove(key)
      k = to_hash_key(key)
      deleted = @params.delete(k)
      deleted.val
    end

    # @param (see #remove))
    # @return val [String] The appropriate param's value
    def get(key)
      k = to_hash_key(key)
      @params[k].val
    end

    # @param (see #add)
    def set(key, val)
      k = to_hash_key(key)
      @params[k].val = val
    end

    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for Param's internal hash.
    # @param dev_input [Symbol | String] Whatever the developer uses as a param key.
    # @!visibility private
    def to_hash_key(dev_in)
      case dev_in
      when String
        k = dev_in.downcase.to_sym
      when Symbol
        k = dev_in.to_s.downcase.to_sym
      end
      k
    end

    # Allows the developer to treat the Params class as a hash, retrieving all param keys.
    # @return [Array<String>] An array of all the param keys stored in the Params object.
    def keys
      @params.keys
    end

    # Used to view internal data
    # @return An array containing all the pairings.
    def show_all
      @params.map { |_, c| { c.key => c.val } }
    end

    # Models a Param's key -> value relationship
    # @!visibility private
    class Param
      attr_accessor :key, :val

      def initialize(key, val)
        @key = key
        @val = val
      end
    end
  end
end
