# frozen_string_literal: true

module JSONAPI

  # Contains all objects relating to a JSONAPI Document
  # @todo Add Response side of the document as well
  class Document

    attr_accessor :data, :included, :meta, :links

    # @query_param data [Data] the already initialized Data class
    # @query_param included [Included] the already initialized Included class
    # @query_param meta [Meta] the already initialized Meta class
    # @query_param links [Links] the already initialized Links class
    def initialize(data, meta, links, included)
      @data = data
      @meta = meta
      @links = links
      @included = included
    end

    def to_s
      '{ ' \
        "data => { #{@data} }, " \
        "meta => { #{@meta} }, " \
        "links => { #{@links} }, " \
        "included => { #{@included} }" \
      ' }'
    end
  end
end
