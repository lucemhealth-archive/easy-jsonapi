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
        "\"data\": #{array_to_string(@data) || 'null'}, " \
        "\"meta\": #{@meta || 'null'}, " \
        "\"links\": #{@links || 'null'}, " \
        "\"errors\": #{array_to_string(@errors) || 'null'}, " \
        "\"jsonapi\": #{@jsonapi || 'null'}, " \
        "\"included\": #{array_to_string(@included) || 'null'}" \
      ' }'
    end

    private

    # Returns the proper to_s for members that are an array.
    def array_to_string(obj_arr)
      return obj_arr unless obj_arr.is_a? Array
      to_return = '['
      first = true
      obj_arr.each do |obj|
        if first
          to_return += obj.to_s
          first = false
        else
          to_return += ", #{obj}"
        end
      end
      to_return += ']'
    end
  end
end
