# frozen_string_literal: true

module JSONAPI

  # Makes the Header class private
  # private_constant :Header

  # Contains all request or response headers
  class Headers
    
    include Enumerable
    
    # Creates a instance variable to store Header objects internally in a hash.
    # @param headers [Array< Array<String> >] The header's key value pairs used by ParseHeaders
    def initialize(headers = [])
      @headers = {}
      headers.each do |p|
        k = to_hash_key(p[0])
        @headers[k] = Header.new(p[0], p[1])
      end
    end

    # Need to implement the #each method in order to make a class enumerable
    def each(&block)
      if block_given?
        @headers.each { |_, hdr| block.call(hdr) }
      else
        to_enum(:each)
      end
    end

    # Adds a header value to a header name
    # @param key [Symbol | String] The header key
    # @param val [String] The header value.
    # @returns headers [Headers] The headers object with another internal header added to it.
    def add(key, val)
      k = to_hash_key(key)
      if @headers[k]
        @headers[k].val = "#{@headers[k].val}, #{val}"
      else
        @headers[k] = Header.new(key, val)
      end
    end

    # Same functionality as #add, adds a header value to a header object if it exists
    #   adds a new header object to Headers if it doesn't
    # @param hdr_arr [Array<String, String>] The key and val of a new header
    # @returns headers [Headers] The headers object with another internal header added to it.
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
    
    # @param (see #include?)
    # @return [Header] the removed header object
    def remove(key)
      k = to_hash_key(key)
      @headers.delete(k)
    end

    # Used when treating header value as more than just a string.
    # # Remove a value from a Header's list of values.
    # # @param (see #add)
    # # @return [Header] the deleted header object
    # def remove(key, val)
    #   k = to_hash_key(key)
    #   hdr = @headers[k]
    #   if hdr?
    #     if hdr.size == 1
    #       return @headers.delete(k)
    #     else
    #       hdr.val = (hdr.val - val)
    #       return Header.new(key, val)
    #     end
    #   end
    # end

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
    
    # Allows the developer to treat the Headers class as a hash, retrieving all header keys.
    # @return [Array<String>] An array of all the header keys stored in the Headers object.
    def keys
      @headers.keys
    end

    # Used to print out the Headers object
    # return [String] The headers object contents represented as a formatted string
    def to_s
      to_return = '['
      is_first = true
      @headers.each do |_, hdr|
        if is_first
          to_return = "#{to_return}#{hdr.to_s}"
          is_first = false
        else
          to_return = "#{to_return}, #{hdr.to_s}"
        end
      end
      to_return += ']'
    end

    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for Header's internal hash.
    # @param dev_input [Symbol | String] Whatever the developer uses as a header key.
    # @!visibility private
    def to_hash_key(dev_in)
      dev_in.to_s.downcase.to_sym
    end

    private :to_hash_key


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
      end
      
      def to_s
        "#{key} => #{val}"
      end
    end
  end
end
