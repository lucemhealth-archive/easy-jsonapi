# frozen_string_literal: true

require 'rack/jsonapi/collection'

module JSONAPI

  # Contains all request or response headers
  class HeaderCollection < Collection

    # Creates a instance variable to store Header objects internally in a hash.
    # @param headers [Array< Array<String> >] The header's key value pairs used by ParseHeaders
    def initialize(arr_of_objs = [])
      @k = proc { |hdr| hdr.key }
      super(arr_of_objs, @k)
    end

    # Need to implement the #each method in order to make a class enumerable
    def each(&block)
      return super.each unless block_given?
      super.each { |_, hdr| block.call(hdr) }
    end

    # Adds a header value to a header name
    # @param key [Symbol | String] The header key
    # @param val [String] The header value.
    # @returns headers [HeaderCollection] The headers object with another internal header added to it.
    def add(hdr)
      super.add(hdr, @key)
    end

    # Same functionality as #add, adds a header value to a header object if it exists
    #   adds a new header object to HeaderCollection if it doesn't
    # @param hdr_arr [Array<String, String>] The key and val of a new header
    # @returns headers [HeaderCollection] The headers object with another internal header added to it.
    def<<(hdr_arr)
      raise ArgumentError, 'wrong number of arguments (given 0, expected 1)' if hdr_arr.nil?
      raise ArgumentError, 'hdr_arr needs to be an array [key, val]' if hdr_arr.size != 2
      
      k = to_hash_key(hdr_arr[0])
      if @headers[k]
        @headers[k].val = "#{@headers[k].val}, #{hdr_arr[1]}"
      else
        @headers[k] = Header.new(hdr_arr[0], hdr_arr[1])
      end 
    end

    # @param key [String | Symbol] the header attribute name
    # @return [TrueClass | FalseClass] whether or not headers contains a header 
    def include?(key)
      k = to_hash_key(key)
      @headers.include? k
    end
    

    # Used when treating header value as more than just a string.
    # Remove a value from a Header's list of values.
    # @param (see #add)
    # @return [Header] the deleted header object
    def remove(key, val = nil)
      k = to_hash_key(key)
      return @headers.delete(k) if val.nil?
      return remove_str(key) if val.class == String
      return remove_index(key) if val.class == Integer
    end

    def remove_str(key)

    end


    # @param (see #remove)
    # @return val [Header] The appropriate header objet
    def get(key)
      k = to_hash_key(key)
      @headers[k]
    end

    # Set the value of a Header if it exists, add a new Header if it doesn't
    # @param (see #add)
    def set(key, val)
      k = to_hash_key(key)
      @headers.include?(k) ? @headers[k].val = val : @headers[k] = Header.new(key, val)
    end
    
    # Allows the developer to treat the HeaderCollection class as a hash, retrieving all header keys.
    # @return [Array<String>] An array of all the header keys stored in the HeaderCollection object.
    def keys
      @headers.keys
    end

    # Used to print out the HeaderCollection object with better formatting
    # return [String] The headers object contents represented as a formatted string
    def to_s
      to_return = '{'
      is_first = true
      @headers.each do |_, hdr|
        if is_first
          to_return = "#{to_return}:#{hdr.key.downcase} => #{hdr.val}"
          is_first = false
        else
          to_return = "#{to_return}, :#{hdr.key.downcase} => #{hdr.val}"
        end
      end
      to_return += '}'
    end

    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for Header's internal hash.
    # @param dev_input [Symbol | String] Whatever the developer uses as a header key.
    # @!visibility private
    def to_hash_key(dev_in)
      dev_in.to_s.downcase.to_sym
    end

    private :to_hash_key, :remove_str, :remove_index


    # Models a Header's key -> value relationship
    class Header
      # @return key [String] a Header's name
      # @return val [Array<String>] a Header's value
      attr_accessor :key, :val
      
      # @param key [String] Header's name
      # @param val [String] the Header's value
      def initialize(key, val)
        @key = key
        @val = val
        # @params
      end
      
      def to_s
        "#{key} => #{val}"
      end
    end
  end
end
