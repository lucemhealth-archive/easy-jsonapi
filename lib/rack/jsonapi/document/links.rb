# frozen_string_literal: true

require 'rack/jsonapi/collection'

module JSONAPI
  class Document
    
    # The links of a resource
    class Links < JSONAPI::Collection

      def initialize(link_arr = [])
        super(link_arr, &:name)
      end

      # #empyt? provided by super class
      # #include provided by super class

      def add(link)
        super(link, &:name)
      end

      # #each provided from super class
      # #remove provided from super class
      # #get provided by super class
      # #keys provided by super class
      # #size provided by super class

      # #to_s provided from super class

      # def method_missing(method_name, *args, &block)
      #   # req.headers.includes == HeaderCollection.new([Include1, Include2])
      # end

      # def respond_to_missing?()
      # end

      # def<<(header)
      #   add(header)
      # end

      # private :insert
    end
  end
end
