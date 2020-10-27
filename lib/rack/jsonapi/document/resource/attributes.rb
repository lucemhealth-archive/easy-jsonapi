# frozen_string_literal: true

require 'rack/jsonapi/collection'

module JSONAPI
  class Document
    class Resource
      # The attributes of a resource
      class Attributes < JSONAPI::Collection
  
        def initialize(attr_arr = [])
          super(attr_arr, &:name)
        end

        # #empyt? provided by super class
        # #include provided by super class

        def add(attribute)
          super(attribute, &:name)
        end

        # #each provided from super class
        # #remove provided from super class
        # #get provided by super class
        # #keys provided by super class
        # #size provided by super class

        # #to_s provided from super class
      end
    end
  end
end
