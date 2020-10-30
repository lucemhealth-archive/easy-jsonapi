# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/name_value_pair'

module JSONAPI
  # The attributes of a resource
  class NameValuePairCollection < JSONAPI::Collection

    # Creates an empty collection by default
    # @param pair_arr [Array<JSONAPI::NameValuePair>] The pairs to be initialized with.
    def initialize(pair_arr = [], class_type = JSONAPI::NameValuePair)
      @class_type = class_type 
      super(pair_arr, &:name)
    end

    # #empyt? provided by super
    # #include provided by super

    def add(pair)
      raise "Cannot add an item that is not #{@class_type}" unless pair.is_a? @class_type
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
      to_return = '{ '
      is_first = true
      each do |pair|
        if is_first
          to_return += pair.to_s
          is_first = false
        else
          to_return += ", #{pair}"
        end
      end
      to_return += ' }'
    end

    protected :insert
  end
end
