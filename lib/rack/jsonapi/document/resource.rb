# frozen_string_literal: true

require 'rack/jsonapi/document/resource_id'

module JSONAPI
  class Document
    # A jsonapi resource object
    class Resource < JSONAPI::Document::ResourceId

      attr_accessor :attributes, :relationships, :links, :meta
      
      def initialize(members_hash)
        super(members_hash[:type], members_hash[:id])
        @attributes = members_hash[:attributes]
        @relationships = members_hash[:relationships]
        @links = members_hash[:links]
        @meta = members_hash[:meta]
      end

      def name
        "#{@type}|#{@id}"
      end

      def to_s
        '{ ' \
          "\"type\": \"#{@type}\", " \
          "\"id\": \"#{@id}\", " \
          "\"attributes\": #{@attributes || 'null'}, " \
          "\"relationships\": #{@relationships || 'null'}, " \
          "\"links\": #{@links || 'null'}, " \
          "\"meta\": #{@meta || 'null'}" \
        '}'
      end
    end
  end
end
