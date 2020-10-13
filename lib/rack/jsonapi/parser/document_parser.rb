# frozen_string_literal: true

require 'rack/jsonapi/document'

# Document parsing logic
module JSONAPI
  module Parser

    # Document Parsing Logic
    module DocumentParser

      TOP_LEVEL_KEY = %w[data included meta links].freeze
      RESOURCE_IDENTIFIER_KEYS = %w[id type].freeze
      # If Relationships present, data must be only member (see creating resource)
      RELATIONSHIP_KEY = 'data'

      # Validate the structure of a JSONAPI request document.
      #
      # @param document [Hash] The supplied JSONAPI document with POST, PATCH, PUT, or DELETE.
      # @raise [JSONAPI::Parser::InvalidDocument] if document is invalid.
      def self.parse!(document)
        
        data = parse_data!(document['data'])
        # parse_included!(document['included']) if document.key?('included')
        JSONAPI::Document.new(data, included, meta, links)
      end

      # Parse as [] or single resource
      def self.parse_data!(data)
        if data.is_a? Hash
          parse_primary_resource!(data)
        elsif data.nil?
          # do nothing
        else
          ensure!(false,
                  'The request MUST include a single resource object as primary data.')
        end
      end

      # ______________________________________________________

      # def self.parse_resource!(res)
      #   ensure!(res.is_a?(Hash), 'A resource object must be an object.')
      #   ensure!(res.key?('id'), 'A resource object must have an id.')
      #   ensure!(res.key?('type'), 'A resource object must have a type.')
      #   parse_attributes!(res['attributes']) if res.key?('attributes')
      #   parse_relationships!(res['relationships']) if res.key?('relationships')
      # end

      # def self.parse_attributes!(attrs)
      #   ensure!(attrs.is_a?(Hash),
      #           'The value of the attributes key MUST be an object.')
      # end

      # def self.parse_relationships!(rels)
      #   ensure!(rels.is_a?(Hash),
      #           'The value of the relationships key MUST be an object')
      #   rels.each_value { |rel| parse_relationship!(rel) }
      # end

      # def self.parse_relationship!(rel)
      #   ensure!(rel.is_a?(Hash), 'A relationship object must be an object.')
      #   ensure!(!rel.keys.empty?,
      #           'A relationship object MUST contain at least one of ' \
      #           "#{RELATIONSHIP_KEYS}")
      #   parse_relationship_data!(rel['data']) if rel.key?('data')
      #   parse_relationship_links!(rel['links']) if rel.key?('links')
      #   parse_meta!(rel['meta']) if rel.key?('meta')
      # end

      # def self.parse_relationship_data!(data)
      #   if data.is_a?(Hash)
      #     parse_resource_identifier!(data)
      #   elsif data.is_a?(Array)
      #     data.each { |ri| parse_resource_identifier!(ri) }
      #   elsif data.nil?
      #     # Do nothing
      #   else
      #     ensure!(false, 'Relationship data must be either nil, an object or ' \
      #                     'an array.')
      #   end
      # end

      # def self.parse_resource_id!(res)
      #   ensure!(res.is_a?(Hash),
      #           'A resource identifier object must be an object')
      #   ensure!(RESOURCE_IDENTIFIER_KEYS & res.keys == RESOURCE_IDENTIFIER_KEYS,
      #           'A resource identifier object MUST contain ' \
      #           "#{RESOURCE_IDENTIFIER_KEYS} members.")
      #   ensure!(res['id'].is_a?(String), 'Member id must be a string.')
      #   ensure!(res['type'].is_a?(String), 'Member type must be a string.')
      # end

      # def self.parse_included!(included)
      #   ensure!(included.is_a?(Array),
      #           'Top level included member must be an array.')
      #   included.each { |res| parse_resource!(res) }
      # end

      def self.ensure!(condition, message)
        raise InvalidDocument, message unless condition
      end
    end
  end
end
