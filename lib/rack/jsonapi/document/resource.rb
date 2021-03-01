# frozen_string_literal: true

require 'rack/jsonapi/document/resource/attributes' # extension
require 'rack/jsonapi/document/resource/relationships' # extension
require 'rack/jsonapi/utility'

module JSONAPI
  class Document
    # A jsonapi resource object
    class Resource

      attr_accessor :attributes, :relationships, :links, :meta, :type, :id
      
      # @param members_hash [Hash] The members to initialize a resource with
      def initialize(members_hash)
        unless members_hash.is_a? Hash
          raise 'A JSONAPI::Document::Resource must be initialized with a Hash'
        end
        @type = members_hash[:type].to_s unless members_hash[:type].nil?
        @id = members_hash[:id].to_s unless members_hash[:id].nil?
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

      # Hash representation of a jsonapi resource
      # @return [Hash] The jsonapi representation of the resource
      def to_h
        to_return = {}
        JSONAPI::Utility.to_h_member(to_return, @type, :type)
        JSONAPI::Utility.to_h_member(to_return, @id, :id)
        JSONAPI::Utility.to_h_member(to_return, @attributes, :attributes)
        JSONAPI::Utility.to_h_member(to_return, @relationships, :relationships)
        JSONAPI::Utility.to_h_member(to_return, @links, :links)
        JSONAPI::Utility.to_h_member(to_return, @meta, :meta)
        to_return
      end
    end
  end
end
