# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'

module JSONAPI
  # header_collection # { include: Include, sort: Sort, filter: Filter } 
  class HeaderCollection < JSONAPI::NameValuePairCollection
    
    # Initialize as empty if a array of Header objects not passed to it.
    # @param header_arr [JSONAPI::HeaderCollection::Header] The array of Header objects that can be used to init
    #   a Header collection
    # @return JSONAPI::HeaderCollection
    def initialize(header_arr = [])
      super(header_arr, item_type: JSONAPI::HeaderCollection::Header)
    end

    # Add a header to the collection. (CASE-INSENSITIVE).
    # @param header [JSONAPI::HeaderCollection::Header] The header to add
    def add(header)
      super(header) { |hdr| hdr.name.downcase.gsub(/-/, '_') }
    end

    # Call super's get but make it case insensitive
    # @param key [Symbol] The hash key associated with a header
    def get(key)
      super(key.to_s.downcase.gsub(/-/, '_'))
    end

    # #empyt? provided by super
    # #include provided by super
    # add provided by super
    # #each provided from super
    # #remove provided from super
    # #keys provided by super
    # #size provided by super

  end  
end
