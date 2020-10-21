# frozen_string_literal: true

module JSONAPI
  class Document
    module Data

      # A jsonapi resource object
      class Resource

        attr_accessor :type, :id, :attributes, :relationships, :links, :meta
        
        def initialize(members_hash)
          @type = members_hash[:type]
          @id = members_hash[:id]
          @attributes = members_hash[:attributes]
          @relationsips = members_hash[:relationships]
          @links = members_hash[:links]
          @meta = members_hash[:meta]
        end
      end
    end
  end
end
