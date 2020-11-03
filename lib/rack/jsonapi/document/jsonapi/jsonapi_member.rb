# frozen_string_literal: true

require 'rack/jsonapi/document/jsonapi'
require 'rack/jsonapi/name_value_pair'

module JSONAPI
  class Document
    class Jsonapi

      # An individual member in a JSON:API Meta object
      class JsonapiMember < JSONAPI::NameValuePair
        
        # TODO: Error checking here or somewhere else?
      end
    end
  end
end
