# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/name_value_pair'
require 'rack/jsonapi/utility'

module JSONAPI
  
  # Collection of Items that all have names and values.
  class NameValuePairCollection < JSONAPI::Collection

    # Creates an empty collection by default
    # @param pair_arr [Array<JSONAPI::NameValuePair>] The pairs to be initialized with.
    def initialize(pair_arr = [], item_type: JSONAPI::NameValuePair, &block)
      if block_given?
        super(pair_arr, item_type: item_type, &block)
      else
        super(pair_arr, item_type: item_type, &:name)
      end
    end

    # #empyt? provided by super
    # #include provided by super

    # Add a pair to the collection. (CASE-SENSITIVE)
    # @param pair [JSONAPI::NameValuePair] The pair to add
    def add(pair, &block)
      if block_given?
        super(pair, &block)
      else
        super(pair, &:name)
      end
    end

    # Another way to add a query_param
    # @oaram (see #add)
    def <<(pair, &block)
      add(pair, &block)
    end

    # #each provided from super
    # #remove provided from super
    # #get provided by super
    # #keys provided by super
    # #size provided by super

    # Represent the collection as a string
    # @return [String] The representation of the collection
    def to_s
      JSONAPI::Utility.to_string_collection(self, pre_string: '{ ', post_string: ' }')
    end

    # Represent the collection as a hash
    # @return [Hash] The representation of the collection
    def to_h
      JSONAPI::Utility.to_h_collection(self)
    end

    protected :insert

    private

    # Gets the NameValuePair object value whose name matches the method_name called
    # @param method_name [Symbol] The name of the method called
    # @param args If any arguments were passed to the method called
    # @param block If a block was passed to the method called
    def method_missing(method_name, *args, &block)
      super unless include?(method_name)
      get(method_name).value
    end

    # Whether or not method missing should be called.
    def respond_to_missing?(method_name, *)
      include?(method_name) || super
    end

  end
end
