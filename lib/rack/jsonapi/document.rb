# frozen_string_literal: true

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

    # To Hash

    private

    def member_to_s(str_name, member, first_member: false)
      return '' if member.nil?
      if first_member
        "\"#{str_name}\": #{array_to_s(member)}"
      else
        ", \"#{str_name}\": #{array_to_s(member)}"
      end
    end

    # Returns the proper to_s for members that are an array.
    def array_to_s(obj_arr)
      return obj_arr.to_s unless obj_arr.is_a? Array
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
