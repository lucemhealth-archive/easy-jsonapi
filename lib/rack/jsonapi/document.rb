# frozen_string_literal: true

module JSONAPI

  # Contains all objects relating to a JSONAPI Document
  # @todo Add Response side of the document as well
  class Document

    attr_accessor :data, :included, :meta, :links

    # @param data [Data] the already initialized Data class
    # @param included [Included] the already initialized Included class
    # @param meta [Meta] the already initialized Meta class
    # @param links [Links] the already initialized Links class
    def initialize(data, meta, links, included)
      @data = data
      @included = included
      @meta = meta
      @links = links
    end
  end
end
