# frozen_string_literal: true

require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/document/resource_id'
require 'rack/jsonapi/document/resource/relationships/relationship'
require 'rack/jsonapi/name_value_pair_collection'

module JSONAPI
  class Document
    class Resource
      # A JSONAPI resource's relationships
      class Relationships < JSONAPI::NameValuePairCollection
        def initialize(rels_obj_arr = [])
          super(rels_obj_arr, JSONAPI::Document::Resource::Relationships::Relationship)
        end
      end
    end
  end
end
