# frozen_string_literal: true

module JSONAPI

  # Makes Page class private
  private_constant :Page

  # Contains all request pagination
  class Pagination
    def initialize(pagination = [])
      @pagination = {}
      pagination.each do |p|
        k = to_hash_key(p[0])
        @pagination[k] = Page.new(p[0], p[1])
      end
    end

    # @param key [Symbol | String] The param key
    # @param val [String] The param value.
    # @returns [Pagination] The pagination object with another internal param added to it.
    def add(key, val)
      k = to_hash_key(key)
      @pagination[k] = Page.new(key, val)
    end

    # @param key [Symbol | String] The param key
    # @return [String] the value of the removed param's value
    def remove(key)
      k = to_hash_key(key)
      deleted = @pagination.delete(k)
      deleted.val
    end

    # @param (see #remove))
    # @return val [String] The appropriate param's value
    def get(key)
      k = to_hash_key(key)
      @pagination[k].val
    end

    # @param (see #add)
    def set(key, val)
      k = to_hash_key(key)
      @pagination[k].val = val
    end

    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for Paginations's internal hash.
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

    # Allows the developer to treat the Pagination class as a hash, retrieving all param keys.
    # @return [Array<String>] An array of all the param keys stored in the Pagination object.
    def keys
      @pagination.map(&:val)
    end

    # Models a Page's key -> value relationship
    # @!visibility private
    class Page
      attr_accessor :key, :val

      def initialize(key, val)
        @key = key
        @val = val
      end
    end
  end
end
