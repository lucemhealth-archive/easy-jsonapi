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
            "\"#{@name}\": { " \
              "\"links\": #{@links || 'null'}, " \
              "\"data\": #{data_to_s || 'null'}, " \
              "\"meta\": #{@meta || 'null'}" \
            ' }' \
          end

          private

          def data_to_s
            case @data
            when Array
              data_str = '['
              first = true
              @data.each do |res|
                if first
                  data_str += res.to_s
                  first = false
                else
                  data_str += ", #{res}"
                end
              end
              data_str += ']'
            when Hash
              data_str += @data.to_s
            when nil
              nil
            else
              raise 'The relationships data member should be a resource identifier or array or resource identifiers'
            end
          end

        end
      end
    end
  end
end
