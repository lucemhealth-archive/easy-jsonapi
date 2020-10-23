# frozen_string_literal: true

module JSONAPI

  # Models a collection of items
  class Collection
    
    include Enumerable
    
    attr_accessor :collection

    def initialize(arr_of_obj = [], &block)
      @collection = {}
      
      return unless (arr_of_obj != []) && block_given?
      arr_of_obj.each do |obj|
        add(obj, &block)
      end
    end

    # Collection.new([
    #   { key: 'include', value: 'authors,comments,likes' },
    #   { key: 'lebron', value: 'james' },
    #   { key: 'charles', value: 'barkley' },
    #   { key: 'michael', value: 'jordan,jackson' },
    #   { key: 'kobe', value: 'bryant' }
    # ]

    # Checks to see if the collection is empty
    # @return [TrueClass | FalseClass]
    def empty?
      @collection == {}
    end

    # Does the collection's internal hash include this key?
    # @query_param key [String | Symbol] The key to search for in the hash
    def include?(key)
      k = to_hash_key(key)
      @collection.include?(k)
    end
    
    def add(item, &block)
      raise 'a block must be passed to #add indicating what should be used as a key' unless block_given?
      insert(block.call(item), item)
    end

    # Adds an item to Collection's internal hash
    def insert(key, item)
      k = to_hash_key(key)
      raise 'The hash key given already has an Item associated with it. ' \
            'Remove existing item first.' if @collection[k]
      @collection[k] = item
    end

    # Yield the block given on all the items in the collection
    def each
      return @collection.each { |_, item| yield(item) } if block_given?
      to_enum(:each)
    end

    # Remove an item from the collection
    # @query_param (see #include)
    # @return [Item | nil] the deleted item object if it exists
    def remove(key)
      k = to_hash_key(key)
      return nil if @collection[k].nil?
      @collection.delete(key)
    end

    # @query_param (see #remove)
    # @return [Item | nil] The appropriate Item objet if it exists
    def get(key)
      k = to_hash_key(key)
      @collection[k]
    end

    # Allows the developer to treat the Collection class as a hash, retrieving all keys mapped to Items.
    # @return [Array<Symbol>] An array of all the item keys stored in the Collection object.
    def keys
      @collection.keys
    end

    # @returns [Integer] The number of items in the collection
    def size
      @collection.size
    end

    # Used to print out the Collection object with better formatting
    # return [String] The collection object contents represented as a formatted string
    def to_s
      to_return = '{ '
      is_first = true
      @collection.each do |k, item|
        if is_first
          to_return += "#{k} => #{item}"
          is_first = false
        else
          to_return += ", #{k} => #{item}"
        end
      end
      to_return += ' }'
    end

    private
    
    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for Collection's internal hash.
    # @query_param input [Symbol | String] Whatever the developer uses as a item key.
    # @!visibility private
    def to_hash_key(input)
      input.to_s.downcase.to_sym
    end
  end
end
