# frozen_string_literal: true

module JSONAPI

  # Abstract class to define functionality for subclasses
  class Pairs
    
    include Enumerable
    
    # Creates a instance variable to store Pair objects internally in a hash.
    # @param pairs_arr [Array< Array<String> >] An array of string arrays, each containing key/vals information
    def initialize(obj_arr)
      @pairs = {}
      pairs_arr.each do |pair_obj|
        @pairs.add(pair_obj)
      end
    end

    # Need to implement the #each method in order to make a class enumerable
    def each(&block)
      if block_given?
        @pairs.each { |_, pair| block.call(pair) }
      else
        to_enum(:each)
      end
    end

    # Adds a pair object to Pairs
    # @param pair [Pair] the Pair object to add
    # @returns pairs [Pairs] The pairs object with another internal pair added to it.
    def add(pair)
      k = to_hash_key(pair.key)
      # If the pair already exists, add the vals to the existing Pair object
      return @pairs[k].add(pair.vals) if @pairs[k]
      # otherwise add the new pair to the pairs object
      @pairs[k] = pair
    end

    # Calls #add with parameter
    # @param (see #add)
    # @returns (see #add)
    def<<(pair)
      add(pair)
    end

    # @param key [String | Symbol] the pair attribute name
    # @return [TrueClass | FalseClass] whether or not pairs contains a pair 
    def include?(key)
      k = to_hash_key(key)
      @pairs.include? k
    end
    
    # Used when treating pair value as more than just a string.
    # Remove a value from a Pair's list of values.
    # @param (see #add)
    # @return [Pair] the deleted pair object
    def remove(key, vals = nil)
      k = to_hash_key(key)
      return @pairs.delete(k) if vals.nil?
      @pairs[k].remove(vals)
    end

    # @param (see #remove)
    # @return [Pair] The appropriate Pair objet
    def get(key)
      k = to_hash_key(key)
      @pairs[k]
    end

    def update(key, vals)
      k = to_hash_key(key)
      @pairs[k].vals = vals if @pairs.include?(k)
    end
    
    # Allows the developer to treat the Pairs class as a hash, retrieving all pair keys.
    # @return [Array<String>] An array of all the pair keys stored in the Pairs object.
    def keys
      @pairs.keys
    end

    # Used to print out the Pairs object with better formatting
    # return [String] The pairs object contents represented as a formatted string
    def to_s
      to_return = '{'
      is_first = true
      @pairs.each do |_, pair|
        if is_first
          to_return += ":#{pair.key.downcase} => #{pair.vals}"
          is_first = false
        else
          to_return += ", :#{pair.key.downcase} => #{pair.vals}"
        end
      end
      to_return += '}'
    end

    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for Pair's internal hash.
    # @param input [Symbol | String] Whatever the developer uses as a pair key.
    # @!visibility private
    def to_hash_key(input)
      input.to_s.downcase.to_sym
    end

    private :to_hash_key


    # Models a Pair's key -> value relationship
    class Pair
      # @return key [String] a Pair's name
      # @return vals [Array<String>] a Pair's values
      attr_accessor :key, :vals
      
      # @param key [String] Pair's name
      # @param vals [String] the Pair's values
      def initialize(key, vals)
        @key = key
        vals = [vals] if vals.is_a?(String)
        @vals = vals
      end

      def add(vals)
        @vals << vals if vals.class == String
        @vals | vals if vals.class == Array
      end

      # TODO: Should you be able to delete all the vals in @vals
      def remove(vals)
        return @vals.delete_at(vals) if vals.class == Integer
        return @vals.delete(vals) if vals.class == String
      end
      
      def to_s
        "#{@key} => #{@vals}"
      end
      
      # def to_s
      #   vals = '['
      #   is_first = true
      #   @vals.each do |e|
      #     if is_first
      #       vals += "\'#{e}\'"
      #       is_first = false
      #     else
      #       vals += ", \'#{e}\'"
      #     end
      #   end
      #   "#{@key} => #{vals}]"
      # end
    end
  end
end
