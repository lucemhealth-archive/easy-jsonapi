# frozen_string_literal: true

require 'rack/jsonapi/document/resource/relationships'
require 'rack/jsonapi/name_value_pair_collection'

module JSONAPI
  class Document
    class Resource
      class Relationships < JSONAPI::NameValuePairCollection
        # The relationships of a resource
        class Relationship
    
          attr_accessor :name, :links, :data, :meta
    
          def initialize(rels_member_obj)
            @name = rels_member_obj[:name]
            @links = rels_member_obj[:links]
            @data = rels_member_obj[:data]
            @meta = rels_member_obj[:meta]
          end
  
          def to_s
            '{ ' \
              "#{@name} => { " \
                "{ links => #{@links} }, " \
                "{ data => #{@data} }, " \
                "{ meta => #{@meta} }, " \
              ' }' \
            ' }'
          end

        end
      end
    end
  end
end
