# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/document/resource/relationships/relationship'

module JSONAPI
  class Document
    class Resource
      # A JSONAPI resource's relationships
      class Relationships < JSONAPI::NameValuePairCollection
        def initialize(rels_obj_arr = [])
          super(rels_obj_arr, item_type: JSONAPI::Document::Resource::Relationships::Relationship)
        end
      end
    end
  end
end
