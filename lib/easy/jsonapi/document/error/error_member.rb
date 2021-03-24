# frozen_string_literal: true

require 'easy/jsonapi/name_value_pair'
require 'easy/jsonapi/document/error'

module JSONAPI
  class Document
    class Error < JSONAPI::NameValuePairCollection

      # An individual error member
      class ErrorMember < JSONAPI::NameValuePair
      end
    end
  end
end
