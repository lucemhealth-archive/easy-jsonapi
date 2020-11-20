# frozen_string_literal: true

module JSONAPI
  class Document
    # A jsonapi resource identifier
    class ResourceId

      attr_accessor :type, :id

      def initialize(type:, id:)
        @type = type.to_s
        @id = id.to_s
      end

      # Represents ResourceId as a JSON parsable string
      def to_s
        "{ \"type\": \"#{@type}\", \"id\": \"#{@id}\" }"
      end

      def to_h
        { type: @type, id: @id }
      end
    end
  end
end
