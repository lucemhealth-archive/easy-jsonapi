# frozen_string_literal: true

require 'rack/jsonapi/document/resource/attributes'
require 'rack/jsonapi/name_value_pair'

module JSONAPI
  class Document
    class Resource
      class Attributes

        # An individual attribute in a JSON:API Attributes object
        class Attribute < JSONAPI::Item::NameValuePair
        end
      end
    end
  end
end
