# frozen_string_literal: true

require 'rack/jsonapi/exceptions/naming_exceptions'

module JSONAPI
  module Exceptions

    # Validates that the request or response document complies with the JSONAPI specification  
    module DocumentExceptions

      # A jsonapi document MUST contain at least one of the following top-level members
      REQUIRED_TOP_LEVEL_KEYS = %i[data errors meta].freeze
      
      # Top level links objects MAY contain the following members
      LINKS_KEYS = %i[self related first prev next last].freeze

      # Each member of a links object is a link. A link MUST be represented as either
      LINK_KEYS = %i[href meta].freeze

      # A resource object MUST contain at least id and type (unless a post resource)
      #   In addition, a resource object MAY contain these top-level members.
      RESOURCE_KEYS = %i[type id attributes relationships links meta].freeze

      # A relationships object MUST contain one of the following:
      RELATIONSHIP_KEYS = %i[data links meta].freeze

      # A relationship that is to-one must conatin at least one of the following.
      TO_ONE_RELATIONSHIP_LINK_KEYS = %i[self related].freeze

      # Every resource object MUST contain an id member and a type member.
      RESOURCE_IDENTIFIER_KEYS = %i[type id].freeze

      # A more specific standard error to raise when an exception is found
      class InvalidDocument < StandardError
      end
      
      # Checks a request document against the JSON:API spec to see if it complies
      # @param document [Hash]  The jsonapi document included with the http request
      # @param is_a_request [TrueClass | FalseClass | NilClass] Whether the document belongs to a http request
      # @param http_method_is_post [TrueClass | FalseClass | NilClass] Whether the document belongs to a post request
      # @raise InvalidDocument if any part of the spec is not observed
      def self.check_compliance(document, is_a_request: nil, http_method_is_post: nil)
        ensure!(!document.nil?, 'A document cannot be nil')
        check_essentials(document, is_a_request: is_a_request, http_method_is_post: http_method_is_post)
        check_members(document, is_a_request: is_a_request, http_method_is_post: http_method_is_post)
        check_member_names(document)
        nil
      end

      # Make helper methods private
      class << self
        private

        # Checks the essentials of a jsonapi document. It is
        #  used by #check_compliance and JSONAPI::Document's #initialize method
        # @param (see #check_compliance)
        def check_essentials(document, is_a_request: nil, http_method_is_post: nil)
          ensure!(document.is_a?(Hash),
                  'A JSON object MUST be at the root of every JSON API request ' \
                  'and response containing data')  
          ensure!(is_a_request || is_a_request.nil? || !http_method_is_post,
                  'A document cannot both belong to a post request and not belong to a request') 
          is_a_request = true if http_method_is_post
          check_top_level(document, is_a_request: is_a_request)
        end

        # **********************************
        # * CHECK TOP LEVEL                *
        # **********************************

        # Checks if there are any errors in the top level hash
        # @param (see *check_compliance)
        # @raise (see check_compliance)
        def check_top_level(document, is_a_request: false)
          ensure!(!(document.keys & REQUIRED_TOP_LEVEL_KEYS).empty?, 
                  'A document MUST contain at least one of the following ' \
                  "top-level members: #{REQUIRED_TOP_LEVEL_KEYS}")
          
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
        # @param (see #check_compliance)
        # @raise (see #check_compliance)
        def check_members(document, is_a_request: false, http_method_is_post: false)
          check_data(document[:data], is_a_request: is_a_request, http_method_is_post: http_method_is_post) if document.key? :data
          check_errors(document[:errors]) if document.key? :errors
          check_meta(document[:meta]) if document.key? :meta
          check_jsonapi(document[:jsonapi]) if document.key? :jsonapi
          check_links(document[:links]) if document.key? :links
          check_included(document[:included]) if document.key? :included
          check_full_linkage(document, is_a_request: is_a_request)
        end

        # -- TOP LEVEL - PRIMARY DATA

        # @param data [Hash | Array<Hash>]  A resource or array or resources
        # @param (see #check_compliance)
        # @param (see #check_compliance)
        # @raise (see #check_compliance)
        def check_data(data, is_a_request: false, http_method_is_post: false)
          ensure!(data.is_a?(Hash) || !is_a_request,
                  'The request MUST include a single resource object as primary data')
          case data
          when Hash
            check_resource(data, http_method_is_post: http_method_is_post)
          when Array
            data.each { |res| check_resource(res) }
          else
            ensure!(data.nil?,
                    'Primary data must be either nil, an object or an array')
          end
        end

        # @param resource [Hash]  The jsonapi resource object
        # @param (see #check_compliance)
        # @raise (see #check_compliance)
        def check_resource(resource, http_method_is_post: false)
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
          # Check for sharing a common namespace is in #check_resource_members
          ensure!(JSONAPI::Exceptions::NamingExceptions.check_member_constraints(resource[:type]).nil?,
                  'The values of type members MUST adhere to the same constraints as member names')
          
          check_resource_members(resource)      
        end

        # Checks whether the resource members conform to the spec
        # @param (see #check_resource)
        # @raise (see #check_compliance)
        def check_resource_members(resource)
          check_attributes(resource[:attributes]) if resource.key? :attributes
          check_relationships(resource[:relationships]) if resource.key? :relationships
          check_meta(resource[:meta]) if resource.key? :meta
          check_links(resource[:links]) if resource.key? :links
          ensure!(shares_common_namespace?(resource[:attributes], resource[:relationships]),
                  'Fields for a resource object MUST share a common namespace with each ' \
                  'other and with type and id')
        end

        # @param attributes [Hash]  The attributes for resource
        # @raise (see #check_compliance)
        def check_attributes(attributes)
          ensure!(attributes.is_a?(Hash),
                  'The value of the attributes key MUST be an object')
          # Attribute members can contain any json value (verified using OJ JSON parser), but
          #   must not contain any attribute or links member
          # TODO: has one foreign keys should not appear as attributes
          # Member names checked separately.
        end

        # @param rels [Hash]  The relationships obj for resource
        # @raise (see #check_compliance)
        def check_relationships(rels)
          ensure!(rels.is_a?(Hash),
                  'The value of the relationships key MUST be an object')
          rels.each_value { |rel| check_relationship(rel) }
        end

        # @param rel [Hash]  A relationship object
        # @raise (see #check_compliance)
        def check_relationship(rel)
          ensure!(rel.is_a?(Hash), 'Each relationships member MUST be a object')
          ensure!(!(rel.keys & RELATIONSHIP_KEYS).empty?,
                  'A relationship object MUST contain at least one of ' \
                  "#{RELATIONSHIP_KEYS}")
          
          # If relationship is a To-Many relationship, the links member may also have pagination links
          #   that traverse the pagination data
          check_relationship_links(rel[:links]) if rel.key? :links
          check_relationship_data(rel[:data]) if rel.key? :data
          check_meta(rel[:meta]) if rel.key? :meta
        end

        # @param links [Hash]  A resources relationships relationship links
        # @raise (see #check_compliance)
        # TODO: If TO-ONE relationship only self and related
        # TODO: If TO-MANY relationship -- self, related, pagination
        def check_relationship_links(links)
          ensure!(!(links.keys & TO_ONE_RELATIONSHIP_LINK_KEYS).empty?,
                  'A relationship link MUST contain at least one of '\
                  "#{TO_ONE_RELATIONSHIP_LINK_KEYS}")
          check_links(links)
        end

        # @param data [Hash] A resources relationships relationship data
        # @raise (see #check_compliance)
        def check_relationship_data(data)
          case data
          when Hash
            check_resource_identifier(data)
          when Array
            data.each { |res_id| check_resource_identifier(res_id) }
          when nil
            # Do nothing
          else
            ensure!(false, 'Resource linkage (relationship data) MUST be either nil, an object or an array')
          end
        end

        # @param res_id [Hash] A resource identifier object
        def check_resource_identifier(res_id)
          ensure!(res_id.is_a?(Hash),
                  'A resource identifier object MUST be an object')
          ensure!((res_id.keys & RESOURCE_IDENTIFIER_KEYS) == RESOURCE_IDENTIFIER_KEYS,
                  'A resource identifier object MUST contain ' \
                  "#{RESOURCE_IDENTIFIER_KEYS} members")
          ensure!(res_id[:id].is_a?(String), 'The resource identifier id member must be a string')
          ensure!(res_id[:type].is_a?(String), 'The resource identifier type member must be a string')
          check_meta(res_id[:meta]) if res_id.key? :meta
        end

        # -- TOP LEVEL - ERRORS

        # @param errors [Array] The array of errors contained in the jsonapi document
        # @raise (see #check_compliance)
        def check_errors(errors)
          ensure!(errors.is_a?(Array),
                  'Top level errors member MUST be an array')
          errors.each { |error| check_error(error) }
        end

        # @param error [Hash] The individual error object
        # @raise (see check_compliance)
        def check_error(error)
          ensure!(error.is_a?(Hash),
                  'Error objects MUST be objects')
          check_links(error[:links]) if error.key? :links
          check_links(error[:meta]) if error.key? :meta
        end

        # -- TOP LEVEL - META

        # @param meta [Hash] The meta object
        # @raise (see check_compliance)
        def check_meta(meta)
          ensure!(meta.is_a?(Hash), 'A meta object MUST be an object')
          # Any members may be specified in a meta obj (all members will be valid json bc string is parsed by oj)
        end

        # -- TOP LEVEL - JSONAPI

        # @param jsonapi [Hash] The top level jsonapi object
        # @raise (see check_compliance)
        def check_jsonapi(jsonapi)
          ensure!(jsonapi.is_a?(Hash), 'A JSONAPI object MUST be an object')
          if jsonapi.key?(:version)
            ensure!(jsonapi[:version].is_a?(String),
                    "The value of JSONAPI's version member MUST be a string")
          end
          check_meta(jsonapi[:meta]) if jsonapi.key?(:meta)
        end

        # -- TOP LEVEL - LINKS

        # @param links [Hash] The links object
        # @raise (see check_compliance)
        def check_links(links)
          ensure!(links.is_a?(Hash), 'A links object MUST be an object')
          links.each_value { |link| check_link(link) }
          nil
        end

        # @param link [String | Hash] A member of the links object
        # @raise (see check_compliance)
        def check_link(link)
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

        # @param included [Array]  The array of included resources
        # @raise (see check_compliance)
        def check_included(included)
          ensure!(included.is_a?(Array),
                  'The top level included member MUST be represented as an array of resource objects')
          included.each { |res| check_resource(res) }
          # Full linkage check is in #check_members
        end

        # Checking if document is fully linked
        # @param document [Hash] The jsonapi document
        # @param is_a_request [TrueClass | FalseClass] Whether it is a request
        def check_full_linkage(document, is_a_request:)
          return nil if is_a_request
          
          # TODO: Possible refactor?
          ensure!(full_linkage?(document),
                  'Compound documents require “full linkage”, meaning that every included resource MUST be ' \
                  'identified by at least one resource identifier object in the same document.')
        end

        

        # **********************************
        # * CHECK MEMBER NAMES             *
        # **********************************
        
        # Checks all the member names in a document recursively and raises an error saying
        #   which member did not observe the jsonapi member name rules and which rule
        # @param obj The entire request document or part of the request document.
        # @raise (see #check_compliance)
        def check_member_names(obj)
          case obj
          when Hash
            obj.each do |k, v| 
              check_name(k)
              check_member_names(v)
            end
          when Array
            obj.each { |hsh| check_member_names(hsh) }
          end
          nil
        end

        # @param name The invidual member's name that is being checked
        # @raise (see check_compliance)
        def check_name(name)
          msg = JSONAPI::Exceptions::NamingExceptions.check_member_constraints(name)
          return if msg.nil?
          raise InvalidDocument, "The member named '#{name}' raised: #{msg}"
        end

        # **********************************
        # * GENERAL HELPER FUNCTIONS       *
        # **********************************
        
        # Helper function to raise InvalidDocument errors
        # @param condition The condition to evaluate
        # @param error_message [String]  The message to raise InvalidDocument with
        # @raise InvalidDocument
        def ensure!(condition, error_message)
          raise InvalidDocument, error_message unless condition
        end
        
        # *****************************************
        # Helper Method for #check_resource_members
        # *****************************************

        # Checks whether a resource's fields share a common namespace
        # @param attributes [Hash] A resource's attributes
        # @param relationships [Hash] A resource's relationships
        def shares_common_namespace?(attributes, relationships)
          true && \
            !contains_type_or_id_member?(attributes) && \
            !contains_type_or_id_member?(relationships) && \
            keys_intersection_empty?(attributes, relationships)
        end

        # @param hash [Hash] The hash to check
        def contains_type_or_id_member?(hash)
          return false unless hash
          hash.key?(:id) || hash.key?(:type)
        end

        # Checks to see if two hashes share any key members names
        # @param arr1 [Array<Symbol>] The first hash key array
        # @param arr2 [Array<Symbol>] The second hash key array
        def keys_intersection_empty?(arr1, arr2)
          return true unless arr1 && arr2
          arr1.keys & arr2.keys == []
        end

        # ********************************
        # Helper Methods for Full Linkage:
        # ********************************

        # @param document [Hash] The jsonapi document hash
        def full_linkage?(document)
          return true unless document[:included] # Checked earlier to make sure included only exists w data
          
          possible_includes = get_possible_includes(document)
          any_additional_includes?(possible_includes, document)
        end

        # Get a collection of all possible includes
        # @param (see #full_linkage?)
        # @return [Hash] Collection of possible includes
        def get_possible_includes(document)
          possible_includes = {}
          primary_data = document[:data]
          include_arr = document[:included]
          populate_w_primary_data(possible_includes, primary_data)
          populate_w_include_mem(possible_includes, include_arr)
          possible_includes
        end

        # @param possible_includes [Hash] The collection of possible includes
        # @document (see #full_linkage?)
        def any_additional_includes?(possible_includes, document)
          document[:included].each do |res|
            return false unless possible_includes.key? res_id_to_sym(res[:type], res[:id])
          end
          true
        end

        # @param possible_includes (see #any_additional_includes?)
        # @param primary_data [Hash] The primary data of a document
        def populate_w_primary_data(possible_includes, primary_data)
          if primary_data.is_a? Array
            primary_data.each do |res|
              populate_w_res_rels(possible_includes, res)
            end
          else
            populate_w_res_rels(possible_includes, primary_data)
          end
        end

        # @param possible_includes (see #any_additional_includes?)
        # @param include_arr [Array<Hash>] The array of includes
        def populate_w_include_mem(possible_includes, include_arr)
          include_arr.each do |res|
            populate_w_res_rels(possible_includes, res)
          end
        end

        # @param possible_includes (see #any_additional_includes?)
        # @param resource [Hash] The resource to check
        def populate_w_res_rels(possible_includes, resource)
          return unless resource[:relationships]
          resource[:relationships].each_value do |rel|
            # pp rel
            res_id = rel[:data]
            next unless res_id

            if res_id.is_a? Array
              res_id.each { |id| possible_includes[res_id_to_sym(id[:type], id[:id])] = true }
            else
              possible_includes[res_id_to_sym(res_id[:type], res_id[:id])] = true
            end
          end
        end

        # Creates a hash key using type and id
        # @param type [String] the resource type
        # @param id [String] the resource id
        def res_id_to_sym(type, id)
          "#{type}|#{id}".to_sym
        end
      end
    end
  end
end
