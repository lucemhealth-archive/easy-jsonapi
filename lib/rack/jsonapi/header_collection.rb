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
      @header_names = []
      super(header_arr, item_type: JSONAPI::HeaderCollection::Header)
    end

    # Add a header to the collection. (CASE-INSENSITIVE).
    # @param header [JSONAPI::HeaderCollection::Header] The header to add
    def add(header)
      h_name = header.name.downcase.gsub(/-/, '_').to_sym
      @header_names << h_name unless @header_names.include?(h_name)
      super(header) { |hdr| hdr.name.downcase }
    end

    # Call super's get but make it case insensitive
    # @param key [Symbol] The hash key associated with a header
    def get(key)
      super(key.downcase)
    end

    # #empyt? provided by super
    # #include provided by super
    # add provided by super
    # #each provided from super
    # #remove provided from super
    # #keys provided by super
    # #size provided by super

    private

    # Gets the Header object whose name matches the method_name called
    # @param method_name [Symbol] The name of the method called
    # @param args If any arguments were passed to the method called
    # @param block If a block was passed to the method called
    def method_missing(method_name, *args, &block)
      super unless @header_names.include?(method_name)
      get(method_name).value
    end

    # Whether or not method missing should be called.
    def respond_to_missing?(method_name, *)
      @header_names.include?(method_name) || super
    end
    
  end  
end
