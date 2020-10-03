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
        add(obj, block)
      end
    end

    def add(item, &block)
      raise 'a block must be passed to #add indicating what should be used as a key' unless block_given?
      insert(block.call(item), item)
    end

    # Another way to call #add
    # @param (see #add)
    # @returns (see #add)
    def<<(item, &block)
      add(item, block)
    end

    # Adds an item to Collection's internal hash
    def insert(key, value)
      k = to_hash_key(key)
      raise 'Item already included. Remove existing item first.' if @collection[k]
      @collection[k] = value
    end

    # Checks to see if the collection is empty
    # @return [TrueClass | FalseClass]
    def empty?
      @collection == {}
    end

    # Yield the block given on all the items in the collection
    def each
      return @collection.each { |_, item| yield(item) } if block_given?
      to_enum(:each)
    end

    # Used when treating item value as more than just a string.
    # Remove a value from a Item's list of values.
    # @param (see #add)
    # @return [Item | nil] the deleted item object if it exists
    def remove(key, val = nil)
      k = to_hash_key(key)
      return nil if @collection[k].nil?
      return @collection.delete(k) if val.nil?
      @collection[k].remove(val)
    end

    # @param (see #remove)
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

    # Used to print out the Collection object with better formatting
    # return [String] The collection object contents represented as a formatted string
    def to_s
      to_return = '{'
      is_first = true
      @collection.each do |k, item|
        if is_first
          to_return += "#{k} => #{item}"
          is_first = false
        else
          to_return += ", #{k} => #{item}"
        end
      end
      to_return += '}'
    end

    # Converts the developer's input into a lowercase symbol to be used as a hash key
    #   for Collection's internal hash.
    # @param input [Symbol | String] Whatever the developer uses as a item key.
    # @!visibility private
    def to_hash_key(input)
      input.to_s.downcase.to_sym
    end

    private :to_hash_key


    # Models a Item's key -> value relationship
    class Item

      
      # obj == { 'articles' => 'title,ody,author', 'people' => 'name' }
      def initialize(obj)
        
        # For each
        obj.each do |key, val|
          instance_variable_set("@#{key}", val) # @key = val
          self.class.send(:define_method, key) do
            # if !(instance_variables.include?("@#{key}")
            #   pp "no method AHHH"
            #   raise NoMethodError "undefined method '#{key}' for #{self.class}"
            # end
            instance_variable_get("@#{key}")
          end

          self.class.send(:define_method, "#{key}=") do |param|
            instance_variable_set("@#{key}", param)
          end
        end
      end

    end
  end
end
