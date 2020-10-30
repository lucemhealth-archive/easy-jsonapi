# frozen_string_literal: true

module JSONAPI
  class Document
    # A jsonapi resource object
    class Resource

      attr_accessor :type, :id, :attributes, :relationships, :links, :meta

      attr_reader :name
      
      def initialize(members_hash)
        @name = 'data'
        @type = members_hash[:type]
        @id = members_hash[:id]
        @attributes = members_hash[:attributes]
        @relationships = members_hash[:relationships]
        @links = members_hash[:links]
        @meta = members_hash[:meta]
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
