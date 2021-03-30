# frozen_string_literal: true

require 'easy/jsonapi/exceptions/user_defined_exceptions'
require 'easy/jsonapi/parser/headers_parser'
require 'easy/jsonapi/utility'

module JSONAPI
  module Exceptions
    # Validates that Headers comply with the JSONAPI specification
    module HeadersExceptions 

      # Media types that are complient with the spec if no parameters are included
      JSONAPI_MEDIA_TYPES = ['application/vnd.api+json', '*/*', 'application/*'].freeze
      
      # A more specific standard error to raise when an exception is found
      class InvalidHeader < StandardError
        attr_accessor :status_code

        # Init w a status code, so that it can be accessed when rescuing an exception
        def initialize(status_code)
          @status_code = status_code
          super
        end
      end

      # Check http verb vs included headers
      # @param env [Hash] The rack environment variable
      # @param config_manager [JSONAPI::ConfigManager] The manager of user configurations
      # @param opts [Hash] Includes http_method, path, and contains_body values
      def self.check_request(env, config_manager = nil, opts = {})
        check_compliance(env, config_manager, opts)
        check_http_method_against_headers(env, opts[:contains_body])
      end

      # Check jsonapi compliance
      # @param (see #check_request)
      def self.check_compliance(env, config_manager = nil, opts = {})
        check_content_type(env)
        check_accept(env)

        hdrs = JSONAPI::Parser::HeadersParser.parse(env)
        usr_opts = { http_method: opts[:http_method], path: opts[:path] }
        err_msg = JSONAPI::Exceptions::UserDefinedExceptions.check_user_header_requirements(hdrs, config_manager, usr_opts)
        raise err_msg unless err_msg.nil?
      end

      class << self
        private

        # Checks the content type of the request to see if it is jsonapi.
        # @param (see #compliant?)
        # @return nil Returns nil if no error found
        # @raise InvalidHeader if not jsonapi compliant
        def check_content_type(env)
          return if content_type_not_included_or_is_compliant?(env['CONTENT_TYPE'])
          
          raise_error('Clients MUST send all JSON:API data in request documents with the header ' \
                      'Content-Type: application/vnd.api+json without any media type parameters.',
                      415)
        end

        # Checks to see the Accept header includes jsonapi without params
        # @param (see #compliant?)
        def check_accept(env)
          return if env['HTTP_ACCEPT'].nil? || # no accept header means compliant
                    contains_at_least_one_jsonapi_media_type_without_params?(env['HTTP_ACCEPT'])

          raise_error('Clients that include the JSON:API media type in their Accept header MUST ' \
                      'specify the media type there at least once without any media type parameters.',
                      406)
        end

        # @param content_type [String | NilClass] The http content-type header
        # @return [TrueClass | FalseClass]
        def content_type_not_included_or_is_compliant?(content_type)
          content_type.nil? || content_type == 'application/vnd.api+json'
        end
        
        # Check the http verb against the content_type and accept header and raise
        #   error if the combination doesn't make sense
        # @param (see #compliant?)
        # @raise InvalidHeader the invalid header incombination with the http verb
        def check_http_method_against_headers(env, contains_body)
          case env['REQUEST_METHOD']
          when 'GET'
            check_get_against_hdrs(env, contains_body)
          when 'POST' || 'PATCH' || 'PUT'
            check_post_against_hdrs(env, contains_body)
          when 'DELETE'
            check_delete_against_hdrs(env, contains_body)
          end
        end

        # Raise error if a GET request has a body or a content type header
        # @param (see #compliant?)
        def check_get_against_hdrs(env, contains_body)
          raise_error('GET requests cannot have a body.') if contains_body
          raise_error("GET request cannot have a 'CONTENT_TYPE' http header.") unless env['CONTENT_TYPE'].nil?
        end

        # POST, PUT, and PATCH request must have a content type header,
        #   a body, and a content-type and accept header that accepts jsonapi
        # @param (see #compliant?)
        def check_post_against_hdrs(env, contains_body)
          raise_error("POST, PUT, and PATCH requests must have a 'CONTENT_TYPE' header.") unless env['CONTENT_TYPE']
          raise_error('POST, PUT, and PATCH requests must have a body.') unless contains_body
          
          return if env['CONTENT_TYPE'] == 'application/vnd.api+json' && accepts_jsonapi?(env)
          
          raise_error('POST, PUT, and PATCH requests must have an ACCEPT header that includes the ' \
                      "JSON:API media type, if they include a JSON:API 'CONTENT_TYPE' header")
        end

        # Raise error if DELETE hdr has a body or a content type header
        def check_delete_against_hdrs(env, contains_body)
          raise_error('DELETE requests cannot have a body.') if contains_body
          raise_error("DELETE request cannot have a 'CONTENT_TYPE' http header.") unless env['CONTENT_TYPE'].nil?
        end
        
        # Check the accept header to see if any of the provided media types indicate that
        #   jsonapi is accepted
        # @param (see #compliant?)
        def accepts_jsonapi?(env)
          return true if env['HTTP_ACCEPT'].nil?
          
          env['HTTP_ACCEPT'].split(',').each do |mt|
            return true if JSONAPI_MEDIA_TYPES.include?(mt)
          end
          false
        end

        # @param accept_hdr [String] The value of the http accept header
        def contains_at_least_one_jsonapi_media_type_without_params?(accept_hdr)
          accept_hdr.split(',').each do |mt|
            if JSONAPI_MEDIA_TYPES.include? mt
              return true
            end
          end
          false
        end

        # Is the media type jsonapi and does it have included parameters
        # @param media_type [String] One of the accepted media types
        # @return [TrueClass | FalseClass]
        def jsonapi_and_has_params?(media_type)
          media_type_split = media_type.split(';')
          JSONAPI_MEDIA_TYPES.include?(media_type_split.first) && \
            contains_media_type_params?(media_type_split)
        end

        # @param msg [String]  The message to raise InvalidHeader with.
        def raise_error(msg, status_code = 400)
          raise InvalidHeader.new(status_code), msg
        end
      end
    end
  end
end
