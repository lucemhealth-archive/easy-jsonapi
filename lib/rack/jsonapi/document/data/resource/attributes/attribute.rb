# frozen_string_literal: true

require 'rack/jsonapi/document/data/resource/attributes'
require 'rack/jsonapi/item'

module JSONAPI
  class Document
    module Data
      class Resource
        class Attributes

          # An individual attribute in a JSON:API Attributes object
          class Attribute < JSONAPI::Item::NameValuePair
          end
        end
      end
    end
  end
end
