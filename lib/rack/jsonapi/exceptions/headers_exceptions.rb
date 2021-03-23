# frozen_string_literal: true

require 'rack/jsonapi/exceptions/user_defined_exceptions'
require 'rack/jsonapi/utility'

module JSONAPI
  module Exceptions
    # Validates that Headers comply with the JSONAPI specification
    module HeadersExceptions 
      
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
      def self.check_request(env, config_manager = nil, opts = {})
        check_compliance(env, config_manager, opts)
        check_http_method_against_headers(env)
      end

      # Check jsonapi compliance
      # @param (see #check_request)
      def self.check_compliance(env, config_manager = nil, opts = {})
        check_content_type(env)
        check_accept(env)

        hdrs = JSONAPI::Parser::HeadersParser.parse(env)
        usr_opts = { http_method: opts[:http_method], path: opts[:path] }
        err_msg = JSONAPI::Exceptions::UserDefinedExceptions.check_user_header_requirements(hdrs, config_manager, usr_opts)
        return err_msg unless err_msg.nil?
      end

      # @param content_type [String | NilClass] The http content-type header
      # @return [TrueClass | FalseClass]
      def self.content_type_not_included_or_is_jsonapi?(content_type)
        content_type.nil? || content_type == 'application/vnd.api+json'
      end

      class << self
        private

        # Checks the content type of the request to see if it is jsonapi.
        #   If it is jsonapi or if it is a different media type it won't raise an error.
        #   It will raise an error if it is jsonapi and includes parameters.
        # @param (see #compliant?)
        # @return nil Returns nil if no error found
        # @raise InvalidHeader if it is jsonapi with parameters
        def check_content_type(env)
          return if content_type_not_included_or_is_jsonapi?(env['CONTENT_TYPE'])
          return unless contains_media_type_params?(env['CONTENT_TYPE']) # no jsonapi w params
          
          raise_error('Clients MUST send all JSON:API data in request documents with the header ' \
                      'Content-Type: application/vnd.api+json without any media type parameters.',
                      415)
        end

        # Checks to see if the JSON:API media type is included in the Accept header, and if
        #   it is, whether it contains media type parameters.
        # @param (see #compliant?)
        def check_accept(env)
          return unless env['HTTP_ACCEPT'] # no accept header means compliant
          return unless all_jsonapi_media_types_have_params?(env['HTTP_ACCEPT'])

          raise_error('Clients that include the JSON:API media type in their Accept header MUST ' \
                      'specify the media type there at least once without any media type parameters.',
                      406)
        end

        # Check the http verb against the content_type and accept header and raise
        #   error if the combination doesn't make sense
        # @param (see #compliant?)
        # @raise InvalidHeader the invalid header incombination with the http verb
        def check_http_method_against_headers(env)
          case env['REQUEST_METHOD']
          when 'GET'
            check_get_against_hdrs(env)
          when 'POST' || 'PATCH' || 'PUT'
            check_post_against_hdrs(env)
          when 'DELETE'
            check_delete_against_hdrs(env)
          end
        end

        # Raise error if a GET request has a body or a content type header
        # @param (see #compliant?)
        def check_get_against_hdrs(env)
          raise_error('GET requests cannot have a body.') unless env['rack.input'].nil?
          raise_error("GET request cannot have a 'CONTENT_TYPE' http header.") unless env['CONTENT_TYPE'].nil?
        end

        # Raise error if POST, PUT, or PATCH has
        def check_post_against_hdrs(env)
          raise_error('POST, PUT, and PATCH requests must have a body.') unless env['rack.input']
          raise_error("POST, PUT, and PATCH requests must have a 'CONTENT_TYPE' header.") unless env['CONTENT_TYPE']
          
          accepts_jsonapi = env['HTTP_ACCEPT'].nil? ||
                            env['HTTP_ACCEPT'].split(',').include?('*/*') ||
                            env['HTTP_ACCEPT'].split(',').include?('application/vnd.api+json')
          return unless env['CONTENT_TYPE'] == 'application/vnd.api+json' && !accepts_jsonapi
          
          raise_error('POST, PUT, and PATCH requests must have an ACCEPT header that includes the ' \
                      "JSON:API media type, if they include a JSON:API 'CONTENT_TYPE' header")
        end

        # Raise error if DELETE hdr has a body or a content type header
        def check_delete_against_hdrs(env)
          raise_error('DELETE requests cannot have a body.') unless env['rack.input'].nil?
          raise_error("DELETE request cannot have a 'CONTENT_TYPE' http header.") unless env['CONTENT_TYPE'].nil?
        end

        # Of the included media types in the accept header, all jsonapi media types
        #   are accompanied by params
        # @param accept_hdr [String] The value of the http accept header
        def all_jsonapi_media_types_have_params?(accept_hdr)
          found_a_jsonapi_mt = false
          found_a_jsonapi_without_params = false
          accepted_mt = accept_hdr.split(',')
          
          accepted_mt.each do |mt|
            if mt == 'application/vnd.api+json'
              found_a_jsonapi_mt = true
              found_a_jsonapi_without_params = true
            elsif mt.include? 'application/vnd.api+json'
              found_a_jsonapi_mt = true
            end
          end

          found_a_jsonapi_mt ^ found_a_jsonapi_without_params
        end

        # Is the media type jsonapi and does it have included parameters
        # @param media_type [String] One of the accepted media types
        # @return [TrueClass | FalseClass]
        def jsonapi_and_has_params?(media_type)
          media_type.include?('application/vnd.api+json') && \
            contains_media_type_params?(media_type)
        end

        # @param (see #jsonapi_and_has_params?)
        # @return (see #jsonapi_and_has_params?)
        def contains_media_type_params?(media_type)
          !media_type.match(%r{\Aapplication/vnd\.api\+json\s?;}).nil?
        end

        # @param msg [String]  The message to raise InvalidHeader with.
        def raise_error(msg, status_code = 400)
          raise InvalidHeader.new(status_code), msg
        end
      end
    end
  end
end
