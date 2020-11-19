# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair'
require 'rack/jsonapi/document/links'

module JSONAPI
  class Document
    class Links < JSONAPI::NameValuePairCollection

      # An individual attribute in a JSON:API Links object
      class Link < JSONAPI::NameValuePair
      end
    end
  end
end
