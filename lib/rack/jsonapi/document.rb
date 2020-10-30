# frozen_string_literal: true

require 'rack/jsonapi/exceptions/document_exceptions'

module JSONAPI

  # Contains all objects relating to a JSONAPI Document
  # @todo Add Response side of the document as well
  class Document

    attr_accessor :data, :meta, :links, :included, :errors, :jsonapi

    # @param document_members_hash [Hash] A hash of the different possible document members
    #   with the values being clases associated with those members
    def initialize(document_members_hash)
      JSONAPI::Exceptions::DocumentExceptions.check_essentials!(document_members_hash)
      @data = document_members_hash[:data]
      @meta = document_members_hash[:meta]
      @links = document_members_hash[:links]
      @included = document_members_hash[:included]
      @errors = document_members_hash[:errors]
      @jsonapi = document_members_hash[:jsonapi]
    end

    # To String
    def to_s
      '{ ' \
        "\"data\": #{@data || 'null'}, " \
        "\"meta\": #{@meta || 'null'}, " \
        "\"links\": #{@links || 'null'}, " \
        "\"errors\": #{@errors || 'null'}, " \
        "\"jsonapi\": #{@jsonapi || 'null'}, " \
        "\"included\": #{@included || 'null'}" \
      ' }'
    end
  end
end
