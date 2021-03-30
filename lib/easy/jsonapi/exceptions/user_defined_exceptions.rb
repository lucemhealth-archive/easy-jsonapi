# frozen_string_literal: true

require 'easy/jsonapi/exceptions/document_exceptions'
require 'easy/jsonapi/exceptions/headers_exceptions'
require 'easy/jsonapi/exceptions/query_params_exceptions'

module JSONAPI
  module Exceptions
    # Allows a user of the gem to define extra requirements they want the middlewar to check for.
    module UserDefinedExceptions

      # Invaliid Document Error when checking user defined restrictions
      class InvalidComponent < StandardError
        attr_accessor :status_code, :msg
  
        def initialize(err)
          @msg = err[0]
          @status_code = err[1] || 400
          super
        end
      end

      # The type of UserDefinedExceptions Error
      class InvalidDocument < InvalidComponent
      end
      
      # The type of UserDefinedExceptions Error
      class InvalidHeader < InvalidComponent
      end
      
      # The type of UserDefinedExceptions Error
      class InvalidQueryParam < InvalidComponent
      end

      class << self

        # Performs compliance checks on the document to see if it complies
        #   to the user defined requirements
        # @param document [Hash] The hash representation of the json body
        # @param config_manager [JSONAPI::ConfigManager] The config_manager option to retreive user
        #   requirements from
        # @return [NilClass | String] Nil or the String Error Message
        def check_user_document_requirements(document, config_manager, opts)
          return if config_manager.nil?
          
          config = get_config(config_manager, opts[:http_method], opts[:path])
          err = check_for_client_generated_id(document, config.allow_client_ids, opts[:http_method])
          
          return if config.default? && config_manager.size.positive?
          
          if err.nil?
            err = check_for_required_document_members(document, config.required_document_members)
          end
          # To add more user requirement features, add more methods here
          
          JSONAPI::Exceptions::UserDefinedExceptions::InvalidDocument.new(err) unless err.nil?
        end

        # Performs compliance checks on the headers to see if it complies
        #   to the user defined requirements
        # @param headers [Hash | JSONAPI::HeaderCollection] The collection of provided headers. Keys should be upper case strings
        #   with underscores instead of dashes.
        # @param config (see #check_user_document_requirements)
        def check_user_header_requirements(headers, config_manager, opts)
          return if config_manager.nil?
          
          config = get_config(config_manager, opts[:http_method], opts[:path])
          return if config.default? && config_manager.size.positive?

          err = 
            check_for_required_headers(headers, config.required_headers)
          # To add more user requirement features, add more methods here

          JSONAPI::Exceptions::UserDefinedExceptions::InvalidHeader.new(err) unless err.nil?
        end

        # Performs compliance checks on the query params to see if it complies
        #   to the user defined requirements
        # @param rack_req_params [Hash]  The hash of the query parameters given by Rack::Request
        # @param config (see #check_user_document_requirements)
        def check_user_query_param_requirements(rack_req_params, config_manager, opts)
          return if config_manager.nil?
          
          config = get_config(config_manager, opts[:http_method], opts[:path])
          return if config.default? && config_manager.size.positive?

          err = 
            check_for_required_params(rack_req_params, config.required_query_params)
          # To add more user requirement features, add more methods here

          JSONAPI::Exceptions::UserDefinedExceptions::InvalidQueryParam.new(err) unless err.nil?
        end

        private

        # ***************************
        # * Document Helper Methods *
        # ***************************

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
          if reached_value_to_check?(document, req_mems)
            return check_values(document, req_mems)
          end
          
          err = check_structure(document, req_mems)
          return err unless err.nil?

          case req_mems
          when Hash
            req_mems.each do |k, v|
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
          if both_are_hashes(document, req_mems)
            doc_keys = document.keys
            req_keys = req_mems.keys
            return if doc_keys & req_keys == req_keys
            ["Document is missing user-defined required keys: #{req_keys - doc_keys}"]
          else 
            return if document.instance_of?(req_mems.class) || req_mems.nil?
            ["User-defined required members hash does not mimic structure of json document: #{document}"]
          end
        end

        def both_are_hashes(first, second)
          first.is_a?(Hash) && second.is_a?(Hash)
        end

        # @return [TrueClass | FalseClass]
        def reached_value_to_check?(document, req_mems)
          (req_mems.is_a?(Proc) || req_mems.nil?) && !document.is_a?(Hash) && !document.is_a?(Array)
        end
        
        # Checks whether a value given is within the permitted values
        # @param value_given [Any]
        def check_values(value_given, permitted_values)
          return if permitted_values.nil? || (permitted_values.is_a?(Proc) && permitted_values.call(value_given))
          ["The user-defined Proc found at #{permitted_values.source_location}, evaluated the given value, #{value_given}, to be non compliant."]
        end
        
        # Checks if a resource id was included in the primary resource sent in a POST request
        # @param document (see# #check_required_document_members)
        # @param allow_client_ids [TrueClass | FalseClass] Does the user allow client generated
        #   ids
        # @param http_method [String] Does the document belong to a POST request
        def check_for_client_generated_id(document, allow_client_ids, http_method)
          return unless http_method == 'POST' && !allow_client_ids
          return unless JSONAPI::Utility.all_hash_path?(document, %i[data id])
          
          msg = 'Document MUST return 403 Forbidden in response to an unsupported request ' \
                'to create a resource with a client-generated ID.'
          [msg, 403]
        end

        # *************************
        # * Header Helper Methods *
        # *************************

        # Checks to makes sure the headers conatin the user defined required headers
        # @param headers [Hash] The provided headers
        # @param req_headers [Hash] The required headers
        def check_for_required_headers(headers, req_headers)
          return if req_headers.nil?

          req_headers.each do |hdr|
            h_name = hdr.to_s.upcase.gsub(/-/, '_')
            unless headers[h_name]
              return ["Headers missing one of the user-defined required headers: #{h_name}"]
            end
          end
          nil
        end

        # ******************************
        # * Query Param Helper Methods *
        # ******************************

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
              return ["Query Params missing one of the user-defined required query params: #{k}"] unless rack_req_params[k.to_s]
              err = check_for_required_params(rack_req_params[k.to_s], v)
              return err unless err.nil?
            end
          when nil
            return
          else
            return ['The user-defined required query params hash must contain keys with values either hash or nil']
          end
          nil
        end

        def get_config(config_manager, http_method, path)
          if http_method
            res_type = JSONAPI::Utility.path_to_res_type(path)
            config_manager[res_type] || config_manager.global
          else
            config_manager.global
          end
        end
      end
    end
  end
end
