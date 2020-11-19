# frozen_string_literal: true

require 'rack/jsonapi/document/resource/attributes' # extension
require 'rack/jsonapi/document/resource/relationships' # extension
require 'rack/jsonapi/utility'

module JSONAPI
  class Document
    # A jsonapi resource object
    class Resource

      attr_accessor :attributes, :relationships, :links, :meta, :type, :id
      
      def initialize(members_hash)
        @type = members_hash[:type].to_s
        @id = members_hash[:id].to_s
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
          "#{JSONAPI::Utility.member_to_s('type', @type, first_member: true)}" \
          "#{JSONAPI::Utility.member_to_s('id', @id)}" \
          "#{JSONAPI::Utility.member_to_s('attributes', @attributes)}" \
          "#{JSONAPI::Utility.member_to_s('relationships', @relationships)}" \
          "#{JSONAPI::Utility.member_to_s('links', @links)}" \
          "#{JSONAPI::Utility.member_to_s('meta', @meta)}" \
        ' }'
      end
    end
  end
end
