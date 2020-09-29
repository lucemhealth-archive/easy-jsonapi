# frozen_string_literal: true

module JSONAPI

  # Makes the Header class private
  # private_constant :Header

  # Contains all request or response headers
  class Headers
    def initialize(headers = [])
      @headers = {}
      headers.each do |p|
        k = to_hash_key(p[0])
        @headers[k] = Header.new(p[0], p[1])
      end
    end

    # @param key [Symbol | String] The header key
    # @param val [String] The header value.
    # @returns [Headers] The headers object with another internal header added to it.
    def add(key, val)
      k = to_hash_key(key)
      @headers[k] = Header.new(key, val)
    end

    # @param key [Symbol | String] The header key
    # @return [String] the value of the removed header's value
    def remove(key)
      k = to_hash_key(key)
      deleted = @headers.delete(k)
      deleted.val
    end

    # @param (see #remove))
    # @return val [String] The appropriate header's value
    def get(key)
      k = to_hash_key(key)
      @headers[k].val
    end

    # @param (see #add)
    def set(key, val)
      k = to_hash_key(key)
      @headers[k].val = val
    end

    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for Header's internal hash.
    # @param dev_input [Symbol | String] Whatever the developer uses as a header key.
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

    # Allows the developer to treat the Headers class as a hash, retrieving all header keys.
    # @return [Array<String>] An array of all the header keys stored in the Headers object.
    def keys
      @headers.keys
    end

    # Used to view internal data
    # @return An array containing all the pairings.
    def show_all
      @headers.map { |_, c| { c.key => c.val } }
    end

    # Models a Header's key -> value relationship
    # @!visibility private
    class Header
      attr_accessor :key, :val

      def initialize(key, val)
        @key = key
        @val = val
      end
    end
  end
end
