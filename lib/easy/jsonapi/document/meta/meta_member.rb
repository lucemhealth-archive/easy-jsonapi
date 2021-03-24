# frozen_string_literal: true

require 'easy/jsonapi/document/meta'

module JSONAPI
  class Document
    class Meta < JSONAPI::NameValuePairCollection

      # An individual member in a JSON:API Meta object
      class MetaMember < JSONAPI::NameValuePair
      end
    end
  end
end
