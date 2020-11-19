# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair'
require 'rack/jsonapi/document/jsonapi'

module JSONAPI
  class Document
    class Jsonapi < JSONAPI::NameValuePairCollection

      # An individual member in a JSON:API Meta object
      class JsonapiMember < JSONAPI::NameValuePair
        
        # TODO: Error checking here or somewhere else?
      end
    end
  end
end
