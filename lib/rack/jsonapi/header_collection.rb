# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'

module JSONAPI
  # header_collection # { include: Include, sort: Sort, filter: Filter } 
  class HeaderCollection < JSONAPI::NameValuePairCollection
    
    def initialize(header_arr = [])
      super(header_arr, JSONAPI::HeaderCollection::Header)
    end

    # #empyt? provided by super
    # #include provided by super
    # add provided by super
    # #each provided from super
    # #remove provided from super
    # #get provided by super
    # #keys provided by super
    # #size provided by super
    
  end  
end
