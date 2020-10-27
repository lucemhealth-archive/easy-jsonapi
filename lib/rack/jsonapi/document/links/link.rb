# frozen_string_literal: true

require 'rack/jsonapi/document/links'
require 'rack/jsonapi/name_value_pair'

module JSONAPI
  class Document
    class Links

      # An individual attribute in a JSON:API Links object
      class Link < JSONAPI::Item::NameValuePair
      end
    end
  end
end
