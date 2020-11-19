# frozen_string_literal: true

require 'rack/jsonapi/document'

module JSONAPI
  module Parser

    # Document Parsing Logic
    module DocumentParser

      # Validate the structure of a JSONAPI request document.
      # @param document [Hash]  The supplied JSONAPI document with POST, PATCH, PUT, or DELETE.
      # @return [JSONAPI::Document] The parsed JSONAPI document.
      # @raise [JSONAPI::Parser::InvalidDocument] if document is invalid.
      def self.parse(document)
        doc_members_hash = parse_top_level_members(document)
        JSONAPI::Document.new(doc_members_hash)
      end

      # @param document (see #parse!)
      # @return [Hash] A hash containing the objects needed to initialize a 
      #   JSONAPI::Document
      def self.parse_top_level_members(document)
        doc_members_hash = {}
        doc_members_hash[:data] = parse_resources(document[:data]) if document.key?(:data)
        doc_members_hash[:meta] = parse_meta(document[:meta]) if document.key?(:meta)
        doc_members_hash[:links] = parse_links(document[:links]) if document.key?(:links)
        doc_members_hash[:included] = parse_included(document[:included]) if document.key?(:included)
        doc_members_hash[:errors] = parse_errors(document[:errors]) if document.key?(:errors)
        doc_members_hash[:jsonapi] = parse_jsonapi(document[:jsonapi]) if document.key?(:jsonapi)
        doc_members_hash
      end

      # @param res_arr [Array<Hash> | Hash] A collection of resources or a resource.
      # @return [JSONAPI::Document::Resource | Array<JSONAPI::Document::Resource>]
      #   A resource or collection of resources
      def self.parse_resources(res_arr)
        case res_arr
        when Array
          res_arr.map { |res| parse_resource(res) }
        when Hash
          parse_resource(res_arr)
        else
          raise 'The top level data member must be an array of resources or a resource'
        end
      end

      # @param res [Hash] The resource hash to parse
      # @return [JSONAPI::Document::Resource] The parsed resource
      def self.parse_resource(res)
        attributes = parse_attributes(res[:attributes]) if res[:attributes]
        relationships = parse_relationships(res[:relationships]) if res[:relationships]
        links = parse_links(res[:links]) if res[:links]
        meta = parse_meta(res[:meta]) if res[:meta]

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

      # @param attrs_hash [Hash] The attributes hash to parse
      # @return [JSONAPI::Document::Resource::Attributes] The parsed attributes
      def self.parse_attributes(attrs_hash)
        attributes = JSONAPI::Document::Resource::Attributes.new
        attrs_hash.each do |name, value|
          cur_attr = JSONAPI::Document::Resource::Attributes::Attribute.new(name, value)
          attributes.add(cur_attr)
        end
        attributes
      end

      # @param rels_hash [Hash] The relationships hash to parse
      # @return [JSONAPI::Document::Resource::Relationships] The parsed
      #   relationships
      def self.parse_relationships(rels_hash)
        relationships = JSONAPI::Document::Resource::Relationships.new
        rels_hash.each do |name, value|
          rel = parse_relationship(name, value)
          relationships.add(rel)
        end
        relationships
      end

      # @param name [String | Symbol] The name of the relationship being parsed
      # @param rel_hash [Hash] The relationship to parse
      # @return [JSONAPI::Document::Resource::Relationships::Relationship]
      #   The parsed relationship
      def self.parse_relationship(name, rel_hash)
        links = parse_links(rel_hash[:links]) if rel_hash[:links]
        data = parse_resource_identifiers(rel_hash[:data]) if rel_hash[:data]
        meta = parse_meta(rel_hash[:meta]) if rel_hash[:meta]
        
        rel_members_hash = { name: name, links: links, data: data, meta: meta }
        JSONAPI::Document::Resource::Relationships::Relationship.new(rel_members_hash)
      end

      # @param links_hash [Hash] The links hash to parse
      # @return [JSONAPI::Document::Links] The parsed links object
      def self.parse_links(links_hash)
        links = JSONAPI::Document::Links.new
        links_hash.each do |name, value|
          cur_link = JSONAPI::Document::Links::Link.new(name, value)
          links.add(cur_link)
        end
        links
      end

      # @param meta_hash [Hash] The meta hash to parse
      # @return [JSONAPI::Document::Meta] The parsed meta object
      def self.parse_meta(meta_hash)
        meta = JSONAPI::Document::Meta.new
        meta_hash.each do |name, value|
          cur_meta_member = JSONAPI::Document::Meta::MetaMember.new(name, value)
          meta.add(cur_meta_member)
        end
        meta
      end

      # @param res_id_arr [Hash | Array<Hash>] The resource identifier or
      #   array of resource identifiers to parse
      # @return [JSONAPI::Document::ResourceId | Array<JSONAPI::Document::ResourceId]
      #   The parsed resource identifier or array or resource identifiers
      def self.parse_resource_identifiers(res_id_arr)
        res_id_hashs = []
        case res_id_arr
        when Array
          res_id_arr.each do |res_id|
            res_id_hashs << parse_resource_identifier(res_id)
          end
          res_id_hashs
        when Hash
          parse_resource_identifier(res_id_arr)
        else
          raise 'Data member of resource relationship was not an array or hash'
        end
      end

      # @param res_id [Hash] The resource identifier to parse
      # @return [JSONAPI::Document::ResourceId] The parsed resource identifier
      def self.parse_resource_identifier(res_id)
        JSONAPI::Document::ResourceId.new(res_id[:type], res_id[:id])
      end

      # @param included_arr [Array<Hash>] The array of included resoures to parse
      # @return [Array<JSONAPI::Document::Resource] The array of parsed included resources
      def self.parse_included(included_arr)
        res_arr = []
        included_arr.each do |res|
          res_arr << parse_resource(res)
        end
        res_arr
      end

      # @param errs_arr [Array<Hash>] The array of errors to parse
      # @return [Array<JSONAPI::Document::Error>] The parsed error objects
      def self.parse_errors(errs_arr)
        errs_hash_arr = []
        errs_arr.each do |err_hash|
          errs_hash_arr << parse_error(err_hash)
        end
        errs_hash_arr
      end

      # @param err_hash [Hash] The error hash to parse
      # @return [JSONAPI::Document::Error] The parsed error object
      def self.parse_error(err_hash)
        error = JSONAPI::Document::Error.new
        err_hash.each do |name, value|
          error.add(JSONAPI::Document::Error::ErrorMember.new(name, value))
        end
        error
      end

    end
  end
end
