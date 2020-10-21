# frozen_string_literal: true

module JSONAPI
  class Document
    module Data
      class Resource

        # The relationships of a resource
        class Relationships
    
          attr_accessor :links, :data, :meta
    
          def initialize(rels_member_hash)
            @links = rels_member_hash[:links]
            @data = rels_member_hash[:data]
            @meta = rels_member_hash[:meta]
          end
        end
      end
    end
  end
end
