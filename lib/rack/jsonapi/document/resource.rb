# frozen_string_literal: true

require 'rack/jsonapi/document/resource_id'

module JSONAPI
  class Document
    # A jsonapi resource object
    class Resource

      attr_accessor :attributes, :relationships, :links, :meta, :type, :id
      
      def initialize(members_hash)
        @type = members_hash[:type]
        @id = members_hash[:id]
        @attributes = members_hash[:attributes]
        @relationships = members_hash[:relationships]
        @links = members_hash[:links]
        @meta = members_hash[:meta]
      end

      # String representation of Document that is JSON parsable
      #   If any document memeber is nil, it does not include it
      #   in the returned string.
      # @return [String] The string representation of a JSONAPI Document
      def to_s
        '{ ' \
          "#{member_to_s('type', @type, first_member: true)}" \
          "#{member_to_s('id', @id)}" \
          "#{member_to_s('attributes', @attributes)}" \
          "#{member_to_s('relationships', @relationships)}" \
          "#{member_to_s('links', @links)}" \
          "#{member_to_s('meta', @meta)}" \
        ' }'
      end

      private

      def member_to_s(str_name, member, first_member: false)
        return '' if member.nil?
        member = "\"#{member}\"" if member.is_a? String
        if first_member
          "\"#{str_name}\": #{member}"
        else
          ", \"#{str_name}\": #{member}"
        end
      end
    end
  end
end
