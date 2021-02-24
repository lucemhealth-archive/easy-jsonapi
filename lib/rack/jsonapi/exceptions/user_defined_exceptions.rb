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
          check_for_required_document_members(document, config&.required_document_members)
          # Add more private method calls to check document for other requirments here
        end

        # Performs compliance checks on the headers to see if it complies
        #   to the user defined requirements
        # @param headers [Hash | JSONAPI::HeaderCollection] The collection of provided headers. Keys should be upper case strings
        #   with underscores instead of dashes.
        # @param config (see #check_user_document_requirements)
        def check_user_header_requirements(headers, config)
          check_for_required_headers(headers, config&.required_headers)
          # Add more private method calls to check document for other requirments here
        end

        # Performs compliance checks on the query params to see if it complies
        #   to the user defined requirements
        # @param rack_req_params [Hash]  The hash of the query parameters given by Rack::Request
        # @param config (see #check_user_document_requirements)
        def check_user_query_param_requiements(rack_req_params, config)
          # Add more private method calls to check document for other requirments here
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
          return if req_mems.nil?

          unless same_class?(document, req_mems)
            return "User-defined required members hash does not mimic structure of json document: #{document}"
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
        
        # Helper for #check_required_document_members. Used to check whether the keys and values
        #   of the document and req_mems hash are the same, excluding when req_mems is nil
        # @param (see #check_required_document_members)
        # @returns [TrueClass | FalseClass] The result of the evaluation
        def same_class?(document, req_mems)
          document.instance_of?(req_mems.class) && !req_mems.nil?
        end

        # Checks to makes sure the headers
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
        end
      end
    end
  end
end
