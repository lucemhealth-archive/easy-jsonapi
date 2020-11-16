# frozen_string_literal: true

require 'rack/jsonapi/document/resource/relationships'
require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/document/resource_id'

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
              "#{member_to_s('links', @links, first_member: true)}" \
              "#{member_to_s('data', @data)}" \
              "#{member_to_s('meta', @meta)}" \
            ' }' \
          end

          private

          # @param str_name [String] The name of the member to stringify
          # @param member One of the relationship's members
          # @param first_member [TrueClass | FalseClass] Whether the current
          #   member is the first member to stringify
          def member_to_s(str_name, member, first_member: false)
            return '' if member.nil?
            if first_member
              "\"#{str_name}\": #{array_to_s(member)}"
            else
              ", \"#{str_name}\": #{array_to_s(member)}"
            end
          end

          # Returns the proper to_s for members regardless of 
          #   whether they are stored as an array or member object
          def array_to_s(obj_arr)
            return obj_arr.to_s unless obj_arr.is_a? Array
            to_return = '['
            first = true
            obj_arr.each do |obj|
              if first
                to_return += obj.to_s
                first = false
              else
                to_return += ", #{obj}"
              end
            end
            to_return += ']'
          end
        end
      end
    end
  end
end
