# frozen_string_literal: true

require 'easy/jsonapi/parser/json_parser'
require 'easy/jsonapi/exceptions/naming_exceptions'
require 'easy/jsonapi/exceptions/user_defined_exceptions'

# TODO: Review document exceptions against jsonapi spec
# TODO: PATCH -- Updating To One Relationships -- The patch request must contain a top level member
#   named data containing either a ResourceID or null
#   ^ To check, create #relationships_link? and make check based on that


module JSONAPI
  module Exceptions

    # Validates that the request or response document complies with the JSONAPI specification  
    module DocumentExceptions

      # A jsonapi document MUST contain at least one of the following top-level members
      REQUIRED_TOP_LEVEL_KEYS = %i[data errors meta].freeze
      
      # Top level links objects MAY contain the following members
      LINKS_KEYS = %i[self related first prev next last].freeze

      # Pagination member names in a links object
      PAGINATION_LINKS =  %i[first prev next last].freeze

      # Each member of a links object is a link. A link MUST be represented as either
      LINK_KEYS = %i[href meta].freeze

      # A resource object MUST contain at least id and type (unless a post resource)
      #   In addition, a resource object MAY contain these top-level members.
      RESOURCE_KEYS = %i[type id attributes relationships links meta].freeze

      # A relationships object MUST contain one of the following:
      RELATIONSHIP_KEYS = %i[data links meta].freeze

      # A relationship that is to-one or to-many must conatin at least one of the following.
      #   A to-many relationship can also contain the addition 'pagination' key.
      TO_ONE_RELATIONSHIP_LINK_KEYS = %i[self related].freeze
      
      # Every resource object MUST contain an id member and a type member.
      RESOURCE_IDENTIFIER_KEYS = %i[type id].freeze

      # A more specific standard error to raise when an exception is found
      class InvalidDocument < StandardError
        attr_accessor :status_code

        # Init w a status code, so that it can be accessed when rescuing an exception
        def initialize(status_code)
          @status_code = status_code
          super
        end
      end
      
      # Checks a request document against the JSON:API spec to see if it complies
      # @param document [String | Hash]  The jsonapi document included with the http request
      # @param opts [Hash] Includes path, http_method, sparse_fieldsets
      # @raise InvalidDocument if any part of the spec is not observed
      def self.check_compliance(document, config_manager = nil, opts = {})
        document = JSONAPI::Parser::JSONParser.parse(document) if document.is_a? String
        ensure!(!document.nil?, 'A document cannot be nil')
        
        check_essentials(document, opts[:http_method])
        check_members(document, opts[:http_method], opts[:path], opts[:sparse_fieldsets])
        check_for_matching_types(document, opts[:http_method], opts[:path])
        check_member_names(document)
        
        usr_opts = { http_method: opts[:http_method], path: opts[:path] }
        err = JSONAPI::Exceptions::UserDefinedExceptions.check_user_document_requirements(document, config_manager, usr_opts)
        raise err unless err.nil?
        
        nil
      end

      # Make helper methods private
      class << self

        # Checks the essentials of a jsonapi document. It is
        #  used by #check_compliance and JSONAPI::Document's #initialize method
        # @param (see #check_compliance)
        def check_essentials(document, http_method)
          ensure!(document.is_a?(Hash),
                  'A JSON object MUST be at the root of every JSON API request ' \
                  'and response containing data')  
          check_top_level(document, http_method)
        end

        # **********************************
        # * CHECK TOP LEVEL                *
        # **********************************

        # Checks if there are any errors in the top level hash
        # @param (see *check_compliance)
        # @raise (see check_compliance)
        def check_top_level(document, http_method)
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
            ensure!(http_method.nil?,
                    'The request MUST include a single resource object as primary data, ' \
                    'unless it is a PATCH request clearing a relationship using a relationship link')
          end
        end

        # **********************************
        # * CHECK TOP LEVEL MEMBERS        *
        # **********************************

        # Checks if any errors exist in the jsonapi document members
        # @param http_method [String] The http verb
        # @param sparse_fieldsets [TrueClass | FalseClass | Nilclass]
        # @raise (see #check_compliance)
        def check_members(document, http_method, path, sparse_fieldsets)
          check_individual_members(document, http_method, path)
          check_full_linkage(document, http_method) unless sparse_fieldsets && http_method.nil?
        end

        # Checks individual members of the jsonapi document for errors
        # @param (see #check_compliance)
        # @raise (see #check_complaince)
        def check_individual_members(document, http_method, path)
          check_data(document[:data], http_method, path) if document.key? :data
          check_included(document[:included]) if document.key? :included
          check_meta(document[:meta]) if document.key? :meta
          check_errors(document[:errors]) if document.key? :errors
          check_jsonapi(document[:jsonapi]) if document.key? :jsonapi
          check_links(document[:links]) if document.key? :links
        end

        # -- TOP LEVEL - PRIMARY DATA

        # @param data [Hash | Array<Hash>]  A resource or array or resources
        # @param (see #check_compliance)
        # @param (see #check_compliance)
        # @raise (see #check_compliance)
        def check_data(data, http_method, path)
          ensure!(data.is_a?(Hash) || http_method.nil? || clearing_relationship_link?(data, http_method, path),
                  'The request MUST include a single resource object as primary data, ' \
                  'unless it is a PATCH request clearing a relationship using a relationship link')
          case data
          when Hash
            check_resource(data, http_method)
          when Array
            data.each { |res| check_resource(res, http_method) }
          else
            ensure!(data.nil?,
                    'Primary data must be either nil, an object or an array')
          end
        end

        # @param resource [Hash]  The jsonapi resource object
        # @param (see #check_compliance)
        # @raise (see #check_compliance)
        def check_resource(resource, http_method = nil)
          if http_method == 'POST'
            ensure!(resource[:type],
                    'The resource object (for a post request) MUST contain at least a type member')
          else
            ensure!((resource[:type] && resource[:id]),
                    'Every resource object MUST contain an id member and a type member')
          end
          ensure!(resource[:type].instance_of?(String),
                  'The value of the resource type member MUST be string')
          if resource[:id]
            ensure!(resource[:id].instance_of?(String),
                    'The value of the resource id member MUST be string')
          end
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
          #   must not contain any attribute or links member -- see #check_full_linkage for this check
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

        # Raise if links don't contain at least one of the TO_ONE_RELATIONSHIP_LINK_KEYS
        # @param links [Hash]  A resource's relationships' relationship-links
        # @raise (see #check_compliance)
        # TODO: If a pagination links are present, they MUST paginate the relationships not the related resource data
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

        # -- TOP LEVEL - INCLUDED

        # @param included [Array]  The array of included resources
        # @raise (see #check_compliance)
        def check_included(included)
          ensure!(included.is_a?(Array),
                  'The top level included member MUST be represented as an array of resource objects')
          
          check_included_resources(included)
          # Full linkage check is in #check_members
        end

        # Check each included resource for compliance and make sure each type/id pair is unique
        # @param (see #check_included)
        # @raise (see #check_compliance)
        def check_included_resources(included)
          no_duplicate_type_and_id_pairs = true
          set = {}
          included.each do |res|
            check_resource(res)
            unless unique_pair?(set, res)
              no_duplicate_type_and_id_pairs = false
              break
            end
          end
          ensure!(no_duplicate_type_and_id_pairs,
                  'A compound document MUST NOT include more ' \
                  'than one resource object for each type and id pair.')
        end

        # @param set [Hash] Set of unique pairs so far
        # @param res [Hash] The resource to inspect
        # @return [TrueClass | FalseClass] Whether the resource has a unique
        #   type and id pair
        def unique_pair?(set, res)
          pair = "#{res[:type]}|#{res[:id]}"
          if set.key?(pair)
            return false
          end
          set[pair] = true
          true
        end

        # -- TOP LEVEL - META

        # @param meta [Hash] The meta object
        # @raise (see check_compliance)
        def check_meta(meta)
          ensure!(meta.is_a?(Hash), 'A meta object MUST be an object')
          # Any members may be specified in a meta obj (all members will be valid json bc string is parsed by oj)
        end

        # -- TOP LEVEL - LINKS

        # FIXME:
        # Pagination Links:
        # Only checked for on response
        # Must only be included in links objects
        # Must Paginate member they are inluded in (relationship vs primary resouce vs compound doc)

        # FIXME:
        # Response Questions:
        # 

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
            ensure!(link[:href].nil? || link[:href].instance_of?(String),
                    'The member href MUST be a string')
            ensure!(link[:meta].nil? || link[:meta].instance_of?(Hash),
                    'The value of each meta member MUST be an object')
          else
            ensure!(false,
                    'A link MUST be represented as either a string or an object')
          end
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

        # -- TOP LEVEL - Check Full Linkage
        
        # Checking if document is fully linked
        # @param document [Hash] The jsonapi document
        # @param http_method (see #check_for_matching_types)
        def check_full_linkage(document, http_method)
          return if http_method
          
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
        # * CHECK FOR MATCHING TYPES       *
        # **********************************

        # Raises a 409 error if the endpoint type does not match the data type on a post request
        # @param document (see #check_compliance)
        # @param http_method [String] The request request method
        # @param path [String] The request path
        def check_for_matching_types(document, http_method, path)
          return unless http_method
          return unless path
          
          return unless JSONAPI::Utility.all_hash_path?(document, %i[data type])
          
          res_type = document[:data][:type]
          case http_method
          when 'POST'
            path_type = path.split('/')[-1]
            check_post_type(path_type, res_type)
          when 'PATCH'
            temp = path.split('/')
            path_type = temp[-2]
            path_id = temp[-1]
            res_id = document.dig(:data, :id)
            check_patch_type(path_type, res_type, path_id, res_id)
          end
        end

        # Raise 409 unless post resource type == endpoint resource type
        # @param path_type [String] The resource type taken from the request path
        # @param res_type [String] The resource type taken from the request body
        # @raise [JSONAPI::Exceptions::DocumentExceptions::InvalidDocument]
        def check_post_type(path_type, res_type)
          ensure!(path_type.to_s.downcase.gsub(/-/, '_') == res_type.to_s.downcase.gsub(/-/, '_'),
                  "When processing a POST request, the resource object's type MUST " \
                  'be amoung the type(s) that constitute the collection represented by the endpoint',
                  status_code: 409)
        end

        # Raise 409 unless path resource type and id == endpoint resource type and id
        # @param path_type [String] The resource type taken from the request path
        # @param res_type [String] The resource type taken from the request body
        # @param path_id [String] The resource id taken from the path
        # @param res_id [String] The resource id taken from the request body
        # @raise [JSONAPI::Exceptions::DocumentExceptions::InvalidDocument]
        def check_patch_type(path_type, res_type, path_id, res_id)
          check = 
            path_type.to_s.downcase.gsub(/-/, '_') == res_type.to_s.downcase.gsub(/-/, '_') &&
            path_id.to_s.downcase.gsub(/-/, '_') == res_id.to_s.downcase.gsub(/-/, '_')
          ensure!(check,
                  "When processing a PATCH request, the resource object's type and id MUST " \
                  "match the server's endpoint",
                  status_code: 409)
        end

        # ********************************
        # * GENERAL HELPER Methods       *
        # ********************************
        
        # Helper function to raise InvalidDocument errors
        # @param condition The condition to evaluate
        # @param error_message [String]  The message to raise InvalidDocument with
        # @raise InvalidDocument
        def ensure!(condition, error_message, status_code: 400)
          raise InvalidDocument.new(status_code), error_message unless condition
        end

        # Helper Method for #check_top_level ---------------------------------

        # TODO: Write tests for clearing_relationship_link
        def clearing_relationship_link?(data, http_method, path)
          http_method == 'PATCH' && data == [] && relationship_link?(path)
        end

        # Does the path length and values indicate that it is a relationsip link
        # @param path [String] The request path
        def relationship_link?(path)
          path_arr = path.split('/')
          path_arr[-2] == 'relationships' && path_arr.length >= 4
        end
        
        # Helper Method for #check_resource_members --------------------------

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

        # Helper Methods for Full Linkage -----------------------------------

        # @param document [Hash] The jsonapi document hash
        def full_linkage?(document)
          return true unless document[:included] 
          # ^ Checked earlier to make sure included only exists w data
          
          possible_includes = get_possible_includes(document)
          any_additional_includes?(possible_includes, document[:included])
        end

        # Get a collection of all possible includes
        #   Need to check relationships on primary resource(s) and also
        #   relationships on the included resource(s)
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
        # @param actual_includes [Hash] The included top level object
        def any_additional_includes?(possible_includes, actual_includes)
          actual_includes.each do |res|
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
