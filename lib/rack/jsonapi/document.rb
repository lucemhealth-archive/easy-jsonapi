# frozen_string_literal: true

module JSONAPI

  # Contains all objects relating to a JSONAPI Document
  # @todo Add Response side of the document as well
  class Document

    # @param data [Data] the already initialized Data class
    # @param included [Included] the already initialized Included class
    # @param meta [Meta] the already initialized Meta class
    # @param links [Links] the already initialized Links class
    def initialize(data, included, meta, links)
      @data = data
      @included = included
      @meta = meta
      @links = links
    end
  end
end

# A document MUST contain at least one of the following top-level members:
# - data: the primary data
#     if updating a To-One relationship - PATCH
#       must include data, and data must be nil or a ResourceId
#     if updating a To-Many relationship- PATCH, POST, DELETE
#       must include data, and data must be [] or a [ResourceId]
# - errors: an array of error objects (only server side)
# - meta: a meta object that contains non-standard meta-information.

# A document MAY contain any of these top-level members:
# - jsonapi: an object describing the highest version of jsonapi supported
# - links: (obj)
# - included: (obj) (only present with data member)
