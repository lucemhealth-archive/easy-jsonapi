# frozen_string_literal: true

require 'rack/jsonapi/exceptions/naming_exceptions'

module JSONAPI
  module Exceptions

    # Validates that the request or response document complies with the JSONAPI specification  
    module DocumentExceptions

      TOP_LEVEL_KEYS = %w[data errors meta jsonapi links included].freeze
      LINKS_KEYS = %w[self related first prev next last].freeze

      RESOURCE_KEYS = %w[type id attributes relationships links meta].freeze
      RESOURCE_IDENTIFIER_KEYS = %w[id type].freeze
      RELATIONSHIP_KEYS = 'data links meta'
      RELATIONSHIP_LINK_KEYS = %w[self related].freeze
      JSONAPI_OBJECT_KEYS = %w[version meta].freeze
      ERROR_KEYS = %w[id links status code title detail source meta].freeze


      class InvalidDocument < StandardError
      end
      
      # Checks a request document against the JSON:API spec to see if it complies
      # @param document [Hash] The jsonapi document included with the http request
      # @param is_a_request [TrueClass | FalseClass] Whether the document belongs to a http request
      # @param is_a_post_request [TrueClass | FalseClass] Whether the document belongs to a post request
      # @raises InvalidDocument if any part of the spec is not observed
      def self.check_compliance!(document, is_a_request, is_a_post_request)
        raise 'Cannot be a post request and not a request' if !is_a_request && is_a_post_request
        check_top_level!(document, is_a_request)
        # check_members!(document, is_a_request, is_a_post_request)
        # check_member_names!(document)
      end

      # Checks if there are any errors in the top level hash
      # @param (see *check_compliance!)
      def self.check_top_level!(document, is_a_request)
        ensure!(document, 
                'A document MUST contain at least one of the following ' \
                "top-level members: #{TOP_LEVEL_KEYS}")
        ensure!(document.is_a?(Hash),
                'A JSON object MUST be at the root of every JSON API request ' \
                'and response containing data.')
        if document.key? 'data'
          ensure!(!document.key?('errors'),
                  'The members data and errors MUST NOT coexist in the same document.')
        else
          ensure!(!document.key?('included'),
                  'If a document does not contain a top-level data key, the included ' \
                  'member MUST NOT be present either.')
          ensure!(!is_a_request,
                  'The request MUST include a single resource object as primary data.')
        end
      end

      # Checks all the member names in a document recursively and raises an error saying
      #   which member did not observe the jsonapi member name rules
      # @param obj The entire request document or part of the request document.
      def self.check_member_names!(obj, member_keys = TOP_LEVEL_KEYS)
        case obj
        when Hash
          new_obj = remove_ignored_members(obj, member_keys)
          new_obj.each_key do |k|
            if obj[k].is_a? Hash
              check_member_names!(obj[k])
            else
              check_member_names!(k)
            end
          end
        when Array
          obj.each { |hsh| check_member_names!(hsh) }
        else
          unless JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?(obj)
            raise InvalidDocument, "The #{obj} member did not follow member name constraints"
          end
        end
        nil
      end

      # The spec states that client / server implementations should ignore extra members, so
      #   check_member_names must remove all non top level members making it's checks
      def self.remove_ignored_members(obj, member_keys)
        keys_to_remove = obj.keys - member_keys
        keys_to_remove.each { |k| obj.delete(k) }
        obj
      end

      # Checks if any errors exist in the jsonapi document members
      # @param (see #check_compliance!)
      def self.check_members!(document, is_a_request, is_a_post_request)
        check_data!(document['data'], is_a_request, is_a_post_request) if document.key? 'data'
        check_errors!(document['errors']) if document.key? 'errors'
        check_included!(document['included']) if document.key? 'included'
        check_jsonapi!(document['jsonapi']) if document.key? 'jsonapi'
        check_meta!(document['meta']) if document.key? 'meta'
        check_links!(document['links']) if document.key? 'links'
      end

      # @param data [Hash | Array<Hash>] A resource or array or resources
      # @param (see #check_compliance!)
      def self.check_data!(data, is_a_request, is_a_post_request)
        case data
        when Hash
          check_resource!(data, is_a_post_request)
        when Array
          ensure!(!is_a_request,
                  'The request MUST include a single resource object as primary data.')
          data.each { |d| check_resource!(d) }
        else
          ensure!(false,
                  'Primary data must be either nil, an object or an array.')
        end
      end

      # @param resource [Hash] The jsonapi resource object
      def self.check_resource!(resource, is_a_post_request = nil)
        pp resource
        if !is_a_post_request
          ensure!((resource['type'] && resource['id']),
                  'Every resource object MUST contain an id member and a type member.')
        else
          ensure!(resource['type'],
                  'The resource object MUST contain at least a type member.')
        end

        if resource['id']
          ensure!(resource['id'].class == String,
                  'The value of the id member MUST be string.')
        end
        ensure!(resource['type'].class == String,
                'The value of the type member MUST be string.')
        ensure!(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?(resource['type']),
                'The values of type members MUST adhere to the same constraints as member names.')
        ensure!((resource.keys - RESOURCE_KEYS).empty?,
                'A resource object MAY only contain the following members: ' \
                'type, id, attributes, relationships, links, meta.')
        # Make sure that type id attributes and relationships share a common namespace
        check_resource_members!(resource)      
      end

      def self.check_resource_members!(resource)
        check_attributes!(resource['attributes']) if resource.key? 'attributes'
        check_relationships!(resource['relationships']) if resource.key? 'relationships'
        check_meta!(resource['meta']) if resource.key? 'meta'
        check_links!(resource['links']) if resource.key? 'links'
      end

      def self.check_attributes!(attributes)
        ensure!(attributes.is_a?(Hash),
                'The value of the attributes key MUST be an object.')
        # must not contain any attribute or links member
        # has one foreign keys should not appear as attributes
      end

      def self.check_relationships!(rels)
        ensure!(rels.is_a?(Hash),
                'The value of the relationships key MUST be an object')
        rels.each_value { |rel| check_relationship!(rel) }
      end

      def self.check_relationship!(rel)
        ensure!(rel.is_a?(Hash), 'A relationship object must be an object.')
        ensure!(!rel.keys.empty?,
                'A relationship object MUST contain at least one of ' \
                "#{RELATIONSHIP_KEYS}")
        check_relationship_data!(rel['data']) if rel.key? 'data'
        check_relationship_links!(rel['links']) if rel.key? 'links'
        check_meta!(rel['meta']) if rel.key? 'meta'
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
                         'an array.')
        end
      end

      def self.check_relationship_links!(links)
        check_links!(links)
        ensure!(!(links.keys & RELATIONSHIP_LINK_KEYS).empty?,
                'A relationship link must contain at least one of '\
                "#{RELATIONSHIP_LINK_KEYS}.")
      end

      def self.check_resource_identifier!(res_id)
        ensure!(res_id.is_a?(Hash),
                'A resource identifier object must be an object')
        ensure!(RESOURCE_IDENTIFIER_KEYS & res_id.keys == RESOURCE_IDENTIFIER_KEYS,
                'A resource identifier object MUST contain ' \
                "#{RESOURCE_IDENTIFIER_KEYS} members.")
        ensure!(res_id['id'].is_a?(String), 'Member id must be a string.')
        ensure!(res_id['type'].is_a?(String), 'Member type must be a string.')
        check_meta!(res_id['meta']) if res_id.key? 'meta'
      end

      def self.check_links!(links)
        ensure!(links.is_a?(Hash), 'A links object must be an object.')
        links.each_value { |link| check_link!(link) }
      end

      # @api private
      def self.check_link!(link)
        case link
        when String
          # Do nothing
        when Hash
          # TODO(beauby): Pending clarification request
          #   https://github.com/json-api/json-api/issues/1103
        else
          ensure!(false,
                  'The value of a link must be either a string or an object.')
        end
      end

      # @api private
      def self.check_meta!(meta)
        ensure!(meta.is_a?(Hash), 'A meta object must be an object.')
      end

      # @api private
      def self.check_jsonapi!(jsonapi)
        ensure!(jsonapi.is_a?(Hash), 'A JSONAPI object must be an object.')
        unexpected_keys = jsonapi.keys - JSONAPI_OBJECT_KEYS
        ensure!(unexpected_keys.empty?,
                'Unexpected members for JSONAPI object: ' \
                "#{JSONAPI_OBJECT_KEYS}.")
        if jsonapi.key?('version')
          ensure!(jsonapi['version'].is_a?(String),
                  "Value of JSONAPI's version member must be a string.")
        end
        check_meta!(jsonapi['meta']) if jsonapi.key?('meta')
      end

      # @api private
      def self.check_included!(included)
        ensure!(included.is_a?(Array),
                'Top level included member must be an array.')
        included.each { |res| check_resource!(res) }
      end

      # @api private
      def self.check_errors!(errors)
        ensure!(errors.is_a?(Array),
                'Top level errors member must be an array.')
        errors.each { |error| check_error!(error) }
      end

      # @api private
      def self.check_error!(_error)
        # NOTE(beauby): Do nothing for now, as errors are under-specified as of
        #   JSONAPI 1.0
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
