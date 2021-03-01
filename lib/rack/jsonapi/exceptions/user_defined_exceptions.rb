# frozen_string_literal: true

require 'rack/jsonapi/exceptions/document_exceptions'
require 'rack/jsonapi/exceptions/headers_exceptions'
require 'rack/jsonapi/exceptions/query_params_exceptions'

module JSONAPI
  module Exceptions
    # Allows a user of the gem to define extra requirements they want the middlewar to check for.
    module UserDefinedExceptions

      class << self

        # Performs compliance checks on the document to see if it complies
        #   to the user defined requirements
        # @param document [Hash] The hash representation of the json body
        # @param config [JSONAPI::Config] The config option to retreive user
        #   requirements from
        def check_user_document_requirements(document, config)
          return unless config
          check_for_required_document_members(document, config.required_document_members)
          # To add more user requirement features, add more methods here
        end

        # Performs compliance checks on the headers to see if it complies
        #   to the user defined requirements
        # @param headers [Hash | JSONAPI::HeaderCollection] The collection of provided headers. Keys should be upper case strings
        #   with underscores instead of dashes.
        # @param config (see #check_user_document_requirements)
        def check_user_header_requirements(headers, config)
          return unless config
          check_for_required_headers(headers, config.required_headers)
          # To add more user requirement features, add more methods here
        end

        # Performs compliance checks on the query params to see if it complies
        #   to the user defined requirements
        # @param rack_req_params [Hash]  The hash of the query parameters given by Rack::Request
        # @param config (see #check_user_document_requirements)
        def check_user_query_param_requirements(rack_req_params, config)
          return unless config
          check_for_required_params(rack_req_params, config.required_query_params)
          # To add more user requirement features, add more methods here
        end

        private

        # Checks to see whether the document conatians all the require members
        #   See spec file for more examples.
        #   Ex: 
        #     { 
        #       data:
        #         [
        #           { 
        #             type: nil, 
        #              attributes: { a1: nil, a2: nil }
        #           }
        #         ],
        #       meta: 
        #         { 
        #           m1: nil
        #         }
        #     }
        # @param document (see #check_user_document_requirements)
        # @param req_mems[Hash] The hash representation of the user-defined required json members.
        def check_for_required_document_members(document, req_mems)
          err = check_structure(document, req_mems)
          return err unless err.nil?

          if req_mems.is_a?(Array) && !document.is_a?(Array)
            return check_values(document, req_mems)
          end

          case req_mems
          when Hash
            req_mems.each do |k, v|
              return "Document is missing one of the user-defined required keys: #{k}" unless document[k]
              err = check_for_required_document_members(document[k], v)
              return err unless err.nil?
            end
          when Array
            document.each do |m|
              err = check_for_required_document_members(m, req_mems.first)
              return err unless err.nil?
            end
          end
          nil
        end          

        # Check if same class or if req_mems nil. If not it indicates the user has specified set
        #   of required values for a given key. Check whether the current valueis within the set.
        # @param (see #check_required_document_members)
        # @return [NilClass | String] An error message if one found.
        def check_structure(document, req_mems)
          return if document.instance_of?(req_mems.class) || req_mems.nil? || req_mems.is_a?(Array)

          "User-defined required members hash does not mimic structure of json document: #{document}"
        end
        
        # Checks whether a value given is within the permitted values
        # @param value_given [Any]
        # @return [NilClass | String] An error msg or nil
        def check_values(value_given, permitted_values)
          return if value_given.is_a?(Hash)
          permitted_values.each do |v|
            return nil if v.to_s.upcase.gsub(/-/, '_') == value_given.to_s.upcase.gsub(/-/, '_')
          end
          
          "The following value was given when only the following #{permitted_values} values are permitted: \"#{value_given}\""
        end

        # Checks to makes sure the headers conatin the user defined required headers
        # @param headers [Hash] The provided headers
        # @param req_headers [Hash] The required headers
        def check_for_required_headers(headers, req_headers)
          return if req_headers.nil?

          req_headers.each do |hdr|
            h_name = hdr.to_s.upcase.gsub(/-/, '_')
            unless headers[h_name]
              return "Headers missing one of the user-defined required headers: #{h_name}"
            end
          end
          nil
        end

        # Checks to make sure the query params contain the user defined required params
        #   Rack Request Params Ex:
        #   {
        #     'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
        #     'include' => 'author,comments-likers,comments.users',
        #     'josh_ua' => 'demoss,simpson',
        #     'page' => { 'offset' => '5', 'limit' => '20' },
        #     'filter' => { 'comments' => '(author/age > 21)', 'users' => '(age < 15)' },
        #     'sort' => 'age,title'
        #   }
        #   Required Params Hash Ex:
        #   {
        #     fields: { articles: nil },
        #     include: nil
        #     page: nil
        #   }
        # @param rack_req_params [Hash] The Rack::Request.params hash
        # @param required_params [Hash] The user defined required query params
        def check_for_required_params(rack_req_params, required_params)
          return if required_params.nil?
          
          case required_params
          when Hash
            required_params.each do |k, v|
              return "Query Params missing one of the user-defined required query params: #{k}" unless rack_req_params[k.to_s]
              err = check_for_required_params(rack_req_params[k.to_s], v)
              return err unless err.nil?
            end
          when nil
            return
          else
            return 'The user-defined required query params hash must contain keys with values either hash or nil'
          end
          nil
        end
      end
    end
  end
end
