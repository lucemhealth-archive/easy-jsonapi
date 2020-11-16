# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/name_value_pair'
require 'rack/jsonapi/utility'

module JSONAPI
  
  # Collection of Items that all have names and values.
  class NameValuePairCollection < JSONAPI::Collection

    # Creates an empty collection by default
    # @param pair_arr [Array<JSONAPI::NameValuePair>] The pairs to be initialized with.
    def initialize(pair_arr = [], item_type: JSONAPI::NameValuePair)
      super(pair_arr, item_type: item_type, &:name)
    end

    # #empyt? provided by super
    # #include provided by super

    def add(pair)
      super(pair, &:name)
    end

    # Another way to add a query_param
    # @oaram (see #add)
    def <<(pair)
      add(pair)
    end

    # #each provided from super
    # #remove provided from super
    # #get provided by super
    # #keys provided by super
    # #size provided by super

    def to_s
      JSONAPI::Utility.to_string_collection(self, pre_string: '{ ', post_string: ' }')
    end

    protected :insert
  end
end
