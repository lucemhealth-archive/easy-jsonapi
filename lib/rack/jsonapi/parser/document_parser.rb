# frozen_string_literal: true

require 'rack/jsonapi/document'

require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/document/resource_id'

require 'rack/jsonapi/document/resource/attributes'
require 'rack/jsonapi/document/resource/attributes/attribute'

require 'rack/jsonapi/document/resource/relationships'
require 'rack/jsonapi/document/resource/relationships/relationship'

require 'rack/jsonapi/document/links'
require 'rack/jsonapi/document/links/link'

require 'rack/jsonapi/document/meta'
require 'rack/jsonapi/document/meta/meta_member'

require 'rack/jsonapi/document/included'

require 'rack/jsonapi/exceptions/document_exceptions'

module JSONAPI
  module Parser

    # Document Parsing Logic
    module DocumentParser

      # Validate the structure of a JSONAPI request document.
      # @query_param document_str [String] The supplied JSONAPI document with POST, PATCH, PUT, or DELETE.
      # @raise [JSONAPI::Parser::InvalidDocument] if document is invalid.
      def self.parse!(document, is_post_request)
        JSONAPI::Exceptions::DocumentExceptions.check_compliance!(document, post_request: is_post_request)
        data = parse_resource!(document[:data]) if document.key?(:data) # Is data required?
        meta = parse_meta!(document[:meta]) if document.key?(:meta)
        links = parse_links!(document[:links]) if document.key?(:links)
        included = parse_included!(document[:included]) if document.key?(:included)

        JSONAPI::Document.new(data, meta, links, included)
      end

      def self.parse_resource!(res)
        attributes = parse_attributes!(res[:attributes]) if res[:attributes]
        relationships = parse_relationships!(res[:relationships]) if res[:relationships]
        links = parse_links!(res[:links]) if res[:links]
        meta = parse_meta!(res[:meta]) if res[:meta]

        res_members_hash = {
          type: res[:type],
          id: res[:id],
          attributes: attributes,
          relationships: relationships,
          links: links,
          meta: meta
        }

        JSONAPI::Document::Resource.new(res_members_hash)
      end

      def self.parse_attributes!(attrs_obj)
        attributes = JSONAPI::Document::Resource::Attributes.new
        attrs_obj.each do |name, value|
          cur_attr = JSONAPI::Document::Resource::Attributes::Attribute.new(name, value)
          attributes.add(cur_attr)
        end
        attributes
      end

      def self.parse_relationships!(rels_obj)
        relationships = JSONAPI::Document::Resource::Relationships.new
        rels_obj.each do |name, value|
          rel = parse_relationship!(name, value)
          relationships.add(rel)
        end
        relationships
      end

      def self.parse_relationship!(name, rel_obj)
        links = parse_links!(rel_obj[:links]) if rel_obj[:links]
        data = parse_resource_identifiers!(rel_obj[:data]) if rel_obj[:data]
        meta = parse_meta!(rel_obj[:meta]) if rel_obj[:meta]
        
        rel_members_obj = { name: name, links: links, data: data, meta: meta }
        JSONAPI::Document::Resource::Relationships::Relationship.new(rel_members_obj)
      end

      def self.parse_links!(link_obj)
        links = JSONAPI::Document::Links.new
        link_obj.each do |name, value|
          cur_link = JSONAPI::Document::Links::Link.new(name, value)
          links.add(cur_link)
        end
        links
      end

      def self.parse_meta!(meta_obj)
        meta = JSONAPI::Document::Meta.new
        meta_obj.each do |name, value|
          cur_meta_member = JSONAPI::Document::Meta::MetaMember.new(name, value)
          meta.add(cur_meta_member)
        end
        meta
      end

      def self.parse_resource_identifiers!(res_id_arr)
        res_id_objs = []
        
        case res_id_arr
        when Array
          res_id_arr.each do |res_id|
            res_id_objs << parse_resource_identifier!(res_id)
          end
        when Hash
          res_id_objs << parse_resource_identifier!(res_id_arr)
        else
          raise 'Data member of resource relationship was not an array or hash'
        end
        res_id_objs
      end

      def self.parse_resource_identifier!(res_id)
        JSONAPI::Document::ResourceId.new(res_id[:type], res_id[:id])
      end

      def self.parse_included!(included_arr)
        res_arr = []
        included_arr.each do |res|
          res_arr << parse_resource!(res)
        end
        JSONAPI::Document::Included.new(res_arr)
      end

    end
  end
end
