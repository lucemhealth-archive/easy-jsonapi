# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'

module JSONAPI
  class Document
    
    # The meta of a resource
    class Meta < JSONAPI::NameValuePairCollection

      def initialize(meta_arr = [])
        super(meta_arr, JSONAPI::Document::Meta::MetaMember)
      end

      # #empyt? provided by super
      # #include provided by super
      # #add provided by supere
      # #each provided from super
      # #remove provided from super
      # #get provided by super
      # #keys provided by super
      # #size provided by super

      # #to_s provided from super

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
