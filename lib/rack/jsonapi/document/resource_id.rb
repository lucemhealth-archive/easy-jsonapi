# frozen_string_literal: true

module JSONAPI
  class Document
    # A jsonapi resource identifier
    class ResourceId

      attr_accessor :type, :id

      # @param type [String | Symbol] The type of the resource identifier
      # @param id [String | Symbol] The id of the resource identifier
      def initialize(type:, id:)
        @type = type.to_s
        @id = id.to_s
      end

      # Represents ResourceId as a JSON parsable string
      def to_s
        "{ \"type\": \"#{@type}\", \"id\": \"#{@id}\" }"
      end

      # Represents ResourceID as a jsonapi hash
      def to_h
        { type: @type, id: @id }
      end
    end
  end
end
