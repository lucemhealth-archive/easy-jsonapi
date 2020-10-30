# frozen_string_literal: true

require 'rack/jsonapi/exceptions/naming_exceptions'

module JSONAPI
  module Exceptions

    # Validates that the request or response document complies with the JSONAPI specification  
    module DocumentExceptions

      TOP_LEVEL_KEYS = %i[data errors meta].freeze
      LINKS_KEYS = %i[self related first prev next last].freeze
      LINK_KEYS = %i[href meta].freeze
      RESOURCE_KEYS = %i[type id attributes relationships links meta].freeze
      RELATIONSHIP_KEYS = %i[data links meta].freeze
      RELATIONSHIP_LINK_KEYS = %i[self related].freeze
      RESOURCE_IDENTIFIER_KEYS = %i[type id].freeze

      # A more specific standard error to raise when an exception is found
      class InvalidDocument < StandardError
      end
      
      # Checks a request document against the JSON:API spec to see if it complies
      # @query_param document [Hash] The jsonapi document included with the http request
      # @query_param request [TrueClass | FalseClass] Whether the document belongs to a http request
      # @query_param http_method_is_post [TrueClass | FalseClass] Whether the document belongs to a post request
      # @raises InvalidDocument if any part of the spec is not observed
      def self.check_compliance!(document, is_a_request: nil, http_method_is_post: nil)
        check_essentials!(document, is_a_request: is_a_request, http_method_is_post: http_method_is_post)
        check_members!(document, is_a_request: is_a_request, http_method_is_post: http_method_is_post)
        check_member_names!(document)
        nil
      end

      # Checks the essentials of a jsonapi document. It is
      #  used by #check_compliance! and JSONAPI::Document's #initialize method
      # @param (see #check_compliance!)
      def self.check_essentials!(document, is_a_request: nil, http_method_is_post: nil)
        raise "Document is nil" if document.nil?
        if http_method_is_post && !is_a_request && !is_a_request.nil?
          raise 'A document cannot both belong to a post request and not belong to a request'
        end
        is_a_request = true if http_method_is_post
        check_top_level!(document, is_a_request: is_a_request)
      end

      # **********************************
      # * CHECK TOP LEVEL                *
      # **********************************

      # Checks if there are any errors in the top level hash
      # @query_param (see *check_compliance!)
      # @raises (see check_compliance!)
      def self.check_top_level!(document, is_a_request: false)
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
          ensure!(!is_a_request,
                  'The request MUST include a single resource object as primary data')
        end
      end

      # **********************************
      # * CHECK TOP LEVEL MEMBERS        *
      # **********************************

      # Checks if any errors exist in the jsonapi document members
      # @query_param (see #check_compliance!)
      # @raises (see #check_compliance!)
      def self.check_members!(document, is_a_request: false, http_method_is_post: false)
        check_data!(document[:data], is_a_request: is_a_request, http_method_is_post: http_method_is_post) if document.key? :data
        check_errors!(document[:errors]) if document.key? :errors
        check_meta!(document[:meta]) if document.key? :meta
        check_jsonapi!(document[:jsonapi]) if document.key? :jsonapi
        check_links!(document[:links]) if document.key? :links
        check_included!(document[:included]) if document.key? :included
      end

      # -- TOP LEVEL - PRIMARY DATA

      # @query_param data [Hash | Array<Hash>] A resource or array or resources
      # @query_param (see #check_compliance!)
      # @query_param (see #check_compliance!)
      # @raises (see #check_compliance!)
      def self.check_data!(data, is_a_request: false, http_method_is_post: false)
        ensure!(data.is_a?(Hash) || !is_a_request,
                'The request MUST include a single resource object as primary data')
        case data
        when Hash
          check_resource!(data, http_method_is_post: http_method_is_post)
        when Array
          data.each { |res| check_resource!(res) }
        else
          ensure!(data.nil?,
                  'Primary data must be either nil, an object or an array')
        end
      end

      # @query_param resource [Hash] The jsonapi resource object
      # @query_param (see #check_compliance!)
      # @raises (see #check_compliance!)
      def self.check_resource!(resource, http_method_is_post: false)
        if !http_method_is_post
          ensure!((resource[:type] && resource[:id]),
                  'Every resource object MUST contain an id member and a type member')
        else
          ensure!(resource[:type],
                  'The resource object (for a post request) MUST contain at least a type member')
        end
        if resource[:id]
          ensure!(resource[:id].class == String,
                  'The value of the resource id member MUST be string')
        end
        ensure!(resource[:type].class == String,
                'The value of the resource type member MUST be string')
        # Make sure that type id attributes and relationships share a common namespace
        ensure!(JSONAPI::Exceptions::NamingExceptions.check_member_constraints(resource[:type]).nil?,
                'The values of type members MUST adhere to the same constraints as member names')
        
        check_resource_members!(resource)      
      end

      # @query_param (see #check_resource!)
      # @raises (see #check_compliance!)
      def self.check_resource_members!(resource)
        check_attributes!(resource[:attributes]) if resource.key? :attributes
        check_relationships!(resource[:relationships]) if resource.key? :relationships
        check_meta!(resource[:meta]) if resource.key? :meta
        check_links!(resource[:links]) if resource.key? :links
      end

      # @query_param attributes [Hash] The attributes for resource
      # @raises (see #check_compliance!)
      def self.check_attributes!(attributes)
        ensure!(attributes.is_a?(Hash),
                'The value of the attributes key MUST be an object')
        # Attribute members can contain any json value (verified using OJ JSON parser), but
        #   must not contain any attribute or links member
        # has one foreign keys should not appear as attributes
        # Member names checked separately.
      end

      # @query_param rels [Hash] The relationships obj for resource
      # @raises (see #check_compliance!)
      def self.check_relationships!(rels)
        ensure!(rels.is_a?(Hash),
                'The value of the relationships key MUST be an object')
        rels.each_value { |rel| check_relationship!(rel) }
      end

      # @query_param rel [Hash] A relationship object
      # @raises (see #check_compliance!)
      def self.check_relationship!(rel)
        ensure!(rel.is_a?(Hash), 'Each relationships member MUST be a object')
        ensure!(!(rel.keys & RELATIONSHIP_KEYS).empty?,
                'A relationship object MUST contain at least one of ' \
                "#{RELATIONSHIP_KEYS}")
        
        # If relationship is a To-Many relationship, the links member may also have pagination links
        #   that traverse the pagination data
        check_relationship_links!(rel[:links]) if rel.key? :links
        check_relationship_data!(rel[:data]) if rel.key? :data
        check_meta!(rel[:meta]) if rel.key? :meta
      end

      # @query_param links [Hash] A resources relationships relationship links
      # @raises (see #check_compliance!)
      def self.check_relationship_links!(links)
        ensure!(!(links.keys & RELATIONSHIP_LINK_KEYS).empty?,
                'A relationship link MUST contain at least one of '\
                "#{RELATIONSHIP_LINK_KEYS}")
        check_links!(links)
      end

      # @query_param data [Hash] A resources relationships relationship data
      # @raises (see #check_compliance!)
      def self.check_relationship_data!(data)
        case data
        when Hash
          check_resource_identifier!(data)
        when Array
          data.each { |res_id| check_resource_identifier!(res_id) }
        when nil
          # Do nothing
        else
          ensure!(false, 'Resource linkage (relationship data) MUST be either nil, an object or an array')
        end
      end

      # @query_param res_id [Hash] A resource identifier object
      def self.check_resource_identifier!(res_id)
        ensure!(res_id.is_a?(Hash),
                'A resource identifier object MUST be an object')
        ensure!((res_id.keys & RESOURCE_IDENTIFIER_KEYS) == RESOURCE_IDENTIFIER_KEYS,
                'A resource identifier object MUST contain ' \
                "#{RESOURCE_IDENTIFIER_KEYS} members")
        ensure!(res_id[:id].is_a?(String), 'The resource identifier id member must be a string')
        ensure!(res_id[:type].is_a?(String), 'The resource identifier type member must be a string')
        check_meta!(res_id[:meta]) if res_id.key? :meta
      end

      # -- TOP LEVEL - ERRORS

      # @query_param errors [Array] The array of errors contained in the jsonapi document
      # @raises (see #check_compliance!)
      def self.check_errors!(errors)
        ensure!(errors.is_a?(Array),
                'Top level errors member MUST be an array')
        errors.each { |error| check_error!(error) }
      end

      # @query_param error [Hash] The individual error object
      # @raises (see check_compliance!)
      def self.check_error!(error)
        ensure!(error.is_a?(Hash),
                'Error objects MUST be objects')
        check_links(error[:links]) if error.key? :links
        check_links(error[:meta]) if error.key? :meta
      end

      # -- TOP LEVEL - META

      # @query_param meta [Hash] The meta object
      # @raises (see check_compliance!)
      def self.check_meta!(meta)
        ensure!(meta.is_a?(Hash), 'A meta object MUST be an object')
        # Any members may be specified in a meta obj (all members will be valid json bc string is parsed by oj)
      end

      # -- TOP LEVEL - JSONAPI

      # @query_param jsonapi [Hash] The top level jsonapi object
      # @raises (see check_compliance!)
      def self.check_jsonapi!(jsonapi)
        ensure!(jsonapi.is_a?(Hash), 'A JSONAPI object MUST be an object')
        if jsonapi.key?(:version)
          ensure!(jsonapi[:version].is_a?(String),
                  "The value of JSONAPI's version member MUST be a string")
        end
        check_meta!(jsonapi[:meta]) if jsonapi.key?(:meta)
      end

      # -- TOP LEVEL - LINKS

      # @query_param links [Hash] The links object
      # @raises (see check_compliance!)
      def self.check_links!(links)
        ensure!(links.is_a?(Hash), 'A links object MUST be an object')
        links.each_value { |link| check_link!(link) }
        nil
      end

      # @query_param link [String | Hash] A member of the links object
      # @raises (see check_compliance!)
      def self.check_link!(link)
        # A link MUST be either a string URL or an object with href / meta
        case link
        when String
          # Do nothing
        when Hash
          ensure!((link.keys - LINK_KEYS).empty?,
                  'If the link is an object, it can contain the members href or meta')
          ensure!(link[:href].nil? || link[:href].class == String,
                  'The member href MUST be a string')
          ensure!(link[:meta].nil? || link[:meta].class == Hash,
                  'The value of each meta member MUST be an object')
        else
          ensure!(false,
                  'A link MUST be represented as either a string or an object')
        end
      end

      # -- TOP LEVEL - INCLUDED

      # @query_param included [Array] The array of included resources
      # @raises (see check_compliance!)
      def self.check_included!(included)
        ensure!(included.is_a?(Array),
                'The top level included member MUST be represented as an array of resource objects')
        included.each { |res| check_resource!(res) }
        # Compound documents require “full linkage”, meaning that every included resource MUST be 
        # identified by at least one resource identifier object in the same document.
      end

      # **********************************
      # * CHECK MEMBER NAMES             *
      # **********************************
      
      # Checks all the member names in a document recursively and raises an error saying
      #   which member did not observe the jsonapi member name rules and which rule
      # @query_param obj The entire request document or part of the request document.
      # @raises (see #check_compliance!)
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

      # @query_param name The invidual member's name that is being checked
      # @raises (see check_compliance!)
      def self.check_name(name)
        msg = JSONAPI::Exceptions::NamingExceptions.check_member_constraints(name)
        return if msg.nil?
        raise InvalidDocument, "The member named '#{name}' raised: #{msg}"
      end

      # **********************************
      # * GENERAL HELPER FUNCTIONS       *
      # **********************************
      
      # Helper function to raise InvalidDocument errors
      # @query_param condition The condition to evaluate
      # @query_param error_message [String] The message to raise InvalidDocument with
      # @raises InvalidDocument
      def self.ensure!(condition, error_message)
        raise InvalidDocument, error_message unless condition
      end
    end
  end
end
