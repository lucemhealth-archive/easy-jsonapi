# frozen_string_literal: true

require 'rack/jsonapi/document'

# Document parsing logic
module ParseDocument

  TOP_LEVEL_KEY = %w[data included meta]
  RESOURCE_IDENTIFIER_KEYS = %w[id type]
  # If Relationships present, data must be only member (see creating resource)
  RELATIONSHIP_KEY = 'data'

  # Validate the structure of a JSONAPI request document.
  #
  # @param document [Hash] The supplied JSONAPI document with POST, PATCH, PUT, or DELETE.
  # @raise [JSONAPI::Parser::InvalidDocument] if document is invalid.
  def self.parse!(document)
    ensure!(document.is_a?(Hash),
            'A JSON object MUST be at the root of every JSON API request ' \
            'and response containing data.')
    ensure!(!(document.keys & TOP_LEVEL_KEY).empty?,
            "A document MUST contain #{TOP_LEVEL_KEY} and only #{TOP_LEVEL_KEY} "\
            ' as a top level member.')
    ensure!(document.key?('data') || !document.key?('included'),
            'If a document does not contain a top-level data key, the ' \
            'included member MUST NOT be present either.')

    parse_data!(document['data'])
    parse_included!(document['included']) if document.key?('included')
  end

  # @api private
  # Parse as [] or single resource
  def self.parse_data!(data)
    if data.is_a?(Hash)
      parse_primary_resource!(data)
    elsif data.is_a?(Array)
      data.each { |res| parse_resource!(res) }
    elsif data.nil?
      # Do nothing
    else
      ensure!(false,
              'Primary data must be either nil, an object or an array.')
    end
  end
  # ______________________________________________________

  # @api private
  def self.parse_resource!(res)
    ensure!(res.is_a?(Hash), 'A resource object must be an object.')
    ensure!(res.key?('id'), 'A resource object must have an id.')
    ensure!(res.key?('type'), 'A resource object must have a type.')
    parse_attributes!(res['attributes']) if res.key?('attributes')
    parse_relationships!(res['relationships']) if res.key?('relationships')
  end

  # @api private
  def self.parse_attributes!(attrs)
    ensure!(attrs.is_a?(Hash),
            'The value of the attributes key MUST be an object.')
  end

  # @api private
  def self.parse_relationships!(rels)
    ensure!(rels.is_a?(Hash),
            'The value of the relationships key MUST be an object')
    rels.values.each { |rel| parse_relationship!(rel) }
  end

  # @api private
  def self.parse_relationship!(rel)
    ensure!(rel.is_a?(Hash), 'A relationship object must be an object.')
    ensure!(!rel.keys.empty?,
            'A relationship object MUST contain at least one of ' \
            "#{RELATIONSHIP_KEYS}")
    parse_relationship_data!(rel['data']) if rel.key?('data')
    parse_relationship_links!(rel['links']) if rel.key?('links')
    parse_meta!(rel['meta']) if rel.key?('meta')
  end

  # @api private
  def self.parse_relationship_data!(data)
    if data.is_a?(Hash)
      parse_resource_identifier!(data)
    elsif data.is_a?(Array)
      data.each { |ri| parse_resource_identifier!(ri) }
    elsif data.nil?
      # Do nothing
    else
      ensure!(false, 'Relationship data must be either nil, an object or ' \
                      'an array.')
    end
  end

  # @api private
  def self.parse_resource_id!(ri)
    ensure!(ri.is_a?(Hash),
            'A resource identifier object must be an object')
    ensure!(RESOURCE_IDENTIFIER_KEYS & ri.keys == RESOURCE_IDENTIFIER_KEYS,
            'A resource identifier object MUST contain ' \
            "#{RESOURCE_IDENTIFIER_KEYS} members.")
    ensure!(ri['id'].is_a?(String), 'Member id must be a string.')
    ensure!(ri['type'].is_a?(String), 'Member type must be a string.')
  end

  # @api private
  def self.parse_included!(included)
    ensure!(included.is_a?(Array),
            'Top level included member must be an array.')
    included.each { |res| parse_resource!(res) }
  end

  # @api private
  def self.ensure!(condition, message)
    raise InvalidDocument, message unless condition
  end
end
