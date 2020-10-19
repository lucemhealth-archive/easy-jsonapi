# frozen_string_literal: true

require 'rack/jsonapi/exceptions/naming_exceptions'

module JSONAPI
  module Exceptions

    # Validates that the request or response document complies with the JSONAPI specification  
    module DocumentExceptions

      TOP_LEVEL_KEYS = %i[data errors meta].freeze
      TOP_LEVEL_LINKS_KEYS = %i[self related first prev next last].freeze
      LINK_KEYS = %i[href meta].freeze

      RESOURCE_KEYS = %i[type id attributes relationships links meta].freeze
      RESOURCE_IDENTIFIER_KEYS = %i[id type].freeze
      RELATIONSHIP_KEYS = %i[data links meta].freeze
      RELATIONSHIP_LINK_KEYS = %i[self related].freeze
      JSONAPI_OBJECT_KEYS = %i[version meta].freeze
      ERROR_KEYS = %i[id links status code title detail source meta].freeze


      class InvalidDocument < StandardError
      end
      
      # Checks a request document against the JSON:API spec to see if it complies
      # @param document [Hash] The jsonapi document included with the http request
      # @param request [TrueClass | FalseClass] Whether the document belongs to a http request
      # @param post_request [TrueClass | FalseClass] Whether the document belongs to a post request
      # @raises InvalidDocument if any part of the spec is not observed
      def self.check_compliance!(document, request: nil, post_request: nil)
        raise "Document is nil" if document.nil?
        raise 'Cannot be a post request and not a request' if post_request && !request && !request.nil?
        request = true if post_request
        check_top_level!(document, request: request)
        check_members!(document, request: request, post_request: post_request)
        check_member_names!(document)
        nil
      end

      # Checks if there are any errors in the top level hash
      # @param (see *check_compliance!)
      def self.check_top_level!(document, request: false)
        ensure!(document.is_a?(Hash),
                'A JSON object MUST be at the root of every JSON API request ' \
                'and response containing data')
        ensure!(!(document.keys & TOP_LEVEL_KEYS).empty?, 
                'A document MUST contain at least one of the following ' \
                "top-level members: #{TOP_LEVEL_KEYS}")
        
        if document.key? :data
          ensure!(!document.key?(:errors),
                  'The members data and errors MUST NOT coexist in the same document')
        else
          ensure!(!document.key?(:included),
                  'If a document does not contain a top-level data key, the included ' \
                  'member MUST NOT be present either')
          ensure!(!request,
                  'The request MUST include a single resource object as primary data')
        end
      end

      # Checks if any errors exist in the jsonapi document members
      # @param (see #check_compliance!)
      def self.check_members!(document, request: false, post_request: false)
        check_top_level_links!(document[:links]) if document.key? :links
        check_data!(document[:data], request: request, post_request: post_request) if document.key? :data
        # check_errors!(document[:errors]) if document.key? :errors
        # check_included!(document[:included]) if document.key? :included
        # check_jsonapi!(document[:jsonapi]) if document.key? :jsonapi
        # check_meta!(document[:meta]) if document.key? :meta
      end

      def self.check_top_level_links!(links)
        ensure!(links.is_a?(Hash), 'A links object must be an object')
        ensure!((links.keys - TOP_LEVEL_LINKS_KEYS).empty?,
                "The top-level links object May contain #{TOP_LEVEL_LINKS_KEYS}")
        links.each_value { |link| check_link!(link) }
        nil
      end

      def self.check_link!(link)
        # A link MUST be either a string URL or an object with href / meta
        case link
        when String
          # Do nothing
        when Hash
          ensure!((link.keys - LINK_KEYS).empty?,
                  'If the link is an object, it can contain the members href or meta')
          ensure!(link[:href].nil? || link[:href].class == String,
                  'The member href should be a string')
          ensure!(link[:meta].nil? || link[:meta].class == Hash,
                  'The value of each meta member MUST be an object')
        else
          ensure!(false,
                  'The value of a link must be either a string or an object')
        end
      end
      
      # @param data [Hash | Array<Hash>] A resource or array or resources
      # @param (see #check_compliance!)
      def self.check_data!(data, request: false, post_request: false)
        ensure!(data.is_a?(Hash) || !request,
                'The request MUST include a single resource object as primary data')
        case data
        when Hash
          check_resource!(data, post_request: post_request)
        when Array
          data.each { |res| check_resource!(res) }
        else
          ensure!(data.nil?,
                  'Primary data must be either nil, an object or an array')
        end
      end

      # @param resource [Hash] The jsonapi resource object
      def self.check_resource!(resource, post_request: false)
        if !post_request
          ensure!((resource[:type] && resource[:id]),
                  'Every resource object MUST contain an id member and a type member')
        else
          ensure!(resource[:type],
                  'The resource object (for a post request) MUST contain at least a type member')
        end
        ensure!((resource.keys - RESOURCE_KEYS).empty?,
                'A resource object MAY only contain the following members: ' \
                'type, id, attributes, relationships, links, meta')
        if resource[:id]
          ensure!(resource[:id].class == String,
                  'The value of the id member MUST be string')
        end
        ensure!(resource[:type].class == String,
                'The value of the type member MUST be string')
        # Make sure that type id attributes and relationships share a common namespace
        ensure!(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?(resource[:type]),
                'The values of type members MUST adhere to the same constraints as member names')
        
        check_resource_members!(resource)      
      end

      def self.check_resource_members!(resource)
        check_attributes!(resource[:attributes]) if resource.key? :attributes
        # check_relationships!(resource[:relationships]) if resource.key? :relationships
        # check_meta!(resource[:meta]) if resource.key? :meta
        # check_links!(resource[:links]) if resource.key? :links
      end

      def self.check_attributes!(attributes)
        ensure!(attributes.is_a?(Hash),
                'The value of the attributes key MUST be an object')
        # Attribute members can contain any json value (verified using OJ JSON parser), but
        #   must not contain any attribute or links member
        # has one foreign keys should not appear as attributes
        # Member names checked separately.
      end

      def self.check_relationships!(rels)
        ensure!(rels.is_a?(Hash),
                'The value of the relationships key MUST be an object')
        rels.each_value { |rel| check_relationship!(rel) }
      end

      def self.check_relationship!(rel)
        ensure!(rel.is_a?(Hash), 'A relationship object must be an object')
        ensure!(!rel.keys.empty?,
                'A relationship object MUST contain at least one of ' \
                "#{RELATIONSHIP_KEYS}")
        check_relationship_data!(rel[:data]) if rel.key? :data
        check_relationship_links!(rel[:links]) if rel.key? :links
        check_meta!(rel[:meta]) if rel.key? :meta
      end

      def self.check_relationship_data!(data)
        if data.is_a?(Hash)
          check_resource_identifier!(data)
        elsif data.is_a?(Array)
          data.each { |res_id| check_resource_identifier!(res_id) }
        elsif data.nil?
          # Do nothing
        else
          ensure!(false, 'Relationship data must be either nil, an object or ' \
                         'an array')
        end
      end

      def self.check_relationship_links!(links)
        check_links!(links)
        ensure!(!(links.keys & RELATIONSHIP_LINK_KEYS).empty?,
                'A relationship link must contain at least one of '\
                "#{RELATIONSHIP_LINK_KEYS}")
      end

      def self.check_resource_identifier!(res_id)
        ensure!(res_id.is_a?(Hash),
                'A resource identifier object must be an object')
        ensure!(RESOURCE_IDENTIFIER_KEYS & res_id.keys == RESOURCE_IDENTIFIER_KEYS,
                'A resource identifier object MUST contain ' \
                "#{RESOURCE_IDENTIFIER_KEYS} members")
        ensure!(res_id[:id].is_a?(String), 'Member id must be a string')
        ensure!(res_id[:type].is_a?(String), 'Member type must be a string')
        check_meta!(res_id[:meta]) if res_id.key? :meta
      end

      def self.check_meta!(meta)
        ensure!(meta.is_a?(Hash), 'A meta object must be an object')
      end

      def self.check_jsonapi!(jsonapi)
        ensure!(jsonapi.is_a?(Hash), 'A JSONAPI object must be an object')
        unexpected_keys = jsonapi.keys - JSONAPI_OBJECT_KEYS
        ensure!(unexpected_keys.empty?,
                'Unexpected members for JSONAPI object: ' \
                "#{JSONAPI_OBJECT_KEYS}")
        if jsonapi.key?('version')
          ensure!(jsonapi[:version].is_a?(String),
                  "Value of JSONAPI's version member must be a string")
        end
        check_meta!(jsonapi[:meta]) if jsonapi.key?(:meta)
      end

      def self.check_included!(included)
        ensure!(included.is_a?(Array),
                'Top level included member must be an array')
        included.each { |res| check_resource!(res) }
      end

      def self.check_errors!(errors)
        ensure!(errors.is_a?(Array),
                'Top level errors member must be an array')
        errors.each { |error| check_error!(error) }
      end

      def self.check_error!(_error)
        # NOTE(beauby): Do nothing for now, as errors are under-specified as of
        #   JSONAPI 1.0
      end

      # Checks all the member names in a document recursively and raises an error saying
      #   which member did not observe the jsonapi member name rules
      # @param obj The entire request document or part of the request document.
      def self.check_member_names!(obj)
        case obj
        when Hash
          obj.each do |k, v| 
            check_name(k)
            check_member_names!(v)
          end
        when Array
          obj.each { |hsh| check_member_names!(hsh) }
        end
        nil
      end

      def self.check_name(name)
        return if JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?(name)
        raise InvalidDocument, "The #{name} member did not follow member name constraints"
      end

      # @param condition The condition to evaluate
      # @param error_message [String] The message to raise InvalidDocument with
      # @raises InvalidDocument
      def self.ensure!(condition, error_message)
        raise InvalidDocument, error_message unless condition
      end
    
    end
    
  end
end

# The top-level links obj MAY contain self, related, pagination

# Resource links
#   a links obj
#   if present, this links object MAY contain a self link that identifies the resouce

# Attributes must not contain a relationships or links member

# A relationships object may contain a link
#   To-One relationship objects:
#     If present, the relationship obj links member must contain self or related
#   To_Many relationship objects:
#     If present, the relationship obj links member must contain self or related OR pagination
#     Any pagination links in a relationship obj MUST paginate the relationship data (not the related resource)

# Each links member must be a link obj
#   a link object MUST be either String URL or obj
#     if an obj, it can only contain href or meta
#       href is String URL
#       meta is a meta obj

# Error Links:
# contains about - a link obj


# ____________

# top_level, resource, relationship, error

def top_level_links(links)

end
