# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair'
require 'rack/jsonapi/document/error'

module JSONAPI
  class Document
    class Error < JSONAPI::NameValuePairCollection

      # An individual error member
      class ErrorMember < JSONAPI::NameValuePair
      end
    end
  end
end
