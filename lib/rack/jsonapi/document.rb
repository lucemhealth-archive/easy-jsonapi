# frozen_string_literal: true

# classes extending document:
require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/document/resource_id'
require 'rack/jsonapi/document/error'
require 'rack/jsonapi/document/jsonapi'
require 'rack/jsonapi/document/links'
require 'rack/jsonapi/document/meta'

require 'rack/jsonapi/utility'

module JSONAPI

  # Contains all objects relating to a JSONAPI Document
  class Document

    attr_reader :data, :meta, :links, :included, :errors, :jsonapi

    # @param document [Hash] A hash of the different possible document members
    #   with the values being clases associated with those members
    def initialize(document = {})
      return unless document.is_a? Hash
      @data = document[:data]
      @meta = document[:meta]
      @links = document[:links] # software generated?
      @included = document[:included]
      @errors = document[:errors]
      @jsonapi = document[:jsonapi] # online documentation
    end

    # To String
    def to_s
      '{ ' \
        "#{JSONAPI::Utility.member_to_s('data', @data, first_member: true)}" \
        "#{JSONAPI::Utility.member_to_s('meta', @meta)}" \
        "#{JSONAPI::Utility.member_to_s('links', @links)}" \
        "#{JSONAPI::Utility.member_to_s('included', @included)}" \
        "#{JSONAPI::Utility.member_to_s('errors', @errors)}" \
        "#{JSONAPI::Utility.member_to_s('jsonapi', @jsonapi)}" \
      ' }'
    end

    def to_h
      to_return = {}
      JSONAPI::Utility.to_h_member(to_return, @data, :data)
      JSONAPI::Utility.to_h_member(to_return, @meta, :meta)
      JSONAPI::Utility.to_h_member(to_return, @links, :links)
      JSONAPI::Utility.to_h_member(to_return, @included, :included)
      JSONAPI::Utility.to_h_member(to_return, @errors, :errors)
      JSONAPI::Utility.to_h_member(to_return, @jsonapi, :jsonapi)
      to_return
    end
  end
end
