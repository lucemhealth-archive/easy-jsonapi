# frozen_string_literal: true

module JSONAPI

  # Contains all objects relating to a JSONAPI Document
  # @todo Add Response side of the document as well
  class Document

    # @param data [Data] the already initialized Data class
    # @param included [Included] the already initialized Included class
    # @param meta [Meta] the already initialized Meta class
    def initialize(data, included, meta)
      @data = data
      @included = included
      @meta = meta
    end
  end
end
