# frozen_string_literal: true

module JSONAPI
  class Document
    # A jsonapi resource identifier
    class ResourceId

      attr_accessor :type, :id
      attr_reader :name

      def initialize(type, id)
        @name = 'data'
        @type = type
        @id = id
      end

      def to_s
        "{ \"type\": \"#{@type}\", \"id\": \"#{@id}\" }"
      end
    end
  end
end
