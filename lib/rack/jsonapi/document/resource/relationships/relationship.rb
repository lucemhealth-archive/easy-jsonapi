# frozen_string_literal: true

require 'rack/jsonapi/utility'

module JSONAPI
  class Document
    class Resource
      class Relationships < JSONAPI::NameValuePairCollection
        # The relationships of a resource
        class Relationship
    
          attr_accessor :links, :data, :meta
          attr_reader :name
    
          def initialize(rels_member_obj)
            # add a relationship, and type
            # need to know one or many
            # object
            @name = rels_member_obj[:name].to_s
            @links = rels_member_obj[:links]
            @data = rels_member_obj[:data]
            @meta = rels_member_obj[:meta]
          end
  
          # @return [String] A JSON parseable representation of a relationship
          def to_s
            "\"#{@name}\": { " \
              "#{JSONAPI::Utility.member_to_s('links', @links, first_member: true)}" \
              "#{JSONAPI::Utility.member_to_s('data', @data)}" \
              "#{JSONAPI::Utility.member_to_s('meta', @meta)}" \
            ' }' \
          end
        end
      end
    end
  end
end
