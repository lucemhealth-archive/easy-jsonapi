# frozen_string_literal: true

module JSONAPI
  # Models a collection of items
  class Collection
    include Enumerable

    # Assume collection is empty not innitialized with an array of objects.
    # @param arr_of_obj [Object] The objects to be stored
    # for block { |item| item[:name] } 
    # @yield [item] Determines what should be used as keys when storing objects in collection's internal hash
    def initialize(arr_of_obj = [], item_type: Object, &block)
      @item_type = item_type
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
    # @param key [String | Symbol]  The key to search for in the hash
    def include?(key)
      @collection.include?(key.to_sym)
    end

    # Add an item to the collection, giving a block to indicate how the
    #   collection should create a hash key for the item.
    # @param item [Object]
    def add(item, &block)
      raise 'a block must be passed to #add indicating what should be used as a key' unless block_given?
      raise "Cannot add an item that is not #{@item_type}" unless item.is_a? @item_type
      insert(block.call(item), item)
    end

    # Adds an item to Collection's internal hash
    def insert(key, item)
      if @collection[key.to_sym]
        raise 'The hash key given already has an Item associated with it. ' \
              'Remove existing item first.'
      end
      @collection[key.to_sym] = item
    end

    # Overwrites the item associated w a given key, or adds an association if no item is already associated.
    def set(key, item)
      raise "Cannot add an item that is not #{@item_type}" unless item.is_a? @item_type
      @collection[key.to_sym] = item
    end

    # Yield the block given on all the items in the collection
    def each
      return @collection.each { |_, item| yield(item) } if block_given?
      to_enum(:each)
    end

    # Remove an item from the collection
    # @param (see #include)
    # @return [Item | nil] the deleted item object if it exists
    def remove(key)
      return nil if @collection[key.to_sym].nil?
      @collection.delete(key.to_sym)
    end

    # @param (see #remove)
    # @return [Item | nil] The appropriate Item object if it exists
    def get(key)
      @collection[key.to_sym]
    end

    # Alias to #get
    # @param (see #get)
    # @param (see #get)
    def [](key)
      get(key)
    end

    # Alias to #set
    # @param (see #set)
    # @param (see #set)
    def []=(key, item)
      set(key, item)
    end

    # Allows the developer to treat the Collection class as a hash, retrieving all keys mapped to Items.
    # @return [Array<Symbol>] An array of all the item keys stored in the Collection object.
    def keys
      @collection.keys
    end

    # @return [Integer] The number of items in the collection
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
          to_return += "\"#{k}\": #{item}"
          is_first = false
        else
          to_return += ", \"#{k}\": #{item}"
        end
      end
      to_return += ' }'
    end
  end
end
