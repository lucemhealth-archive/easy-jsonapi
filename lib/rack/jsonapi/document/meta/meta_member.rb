# frozen_string_literal: true

require 'rack/jsonapi/document/meta'
require 'rack/jsonapi/name_value_pair'

module JSONAPI
  class Document
    class Meta

      # An individual attribute in a JSON:API Meta object
      class MetaMember < JSONAPI::Item::NameValuePair
      end
    end
  end
end
