# frozen_string_literal: true

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

      # @param env [Hash]  The rack environment variable
      def self.check_compliance(env)
        check_content_type(env)
        check_accept(env)
      end

      # Checks the content type of the request to see if it is jsonapi.
      #   If it is jsonapi or if it is a different media type it won't raise an error.
      #   It will raise an error if it is jsonapi and includes parameters.
      # @param (see #compliant?)
      # @return nil Returns nil if no error found
      # @raise InvalidHeader if it is jsonapi with parameters
      def self.check_content_type(env)
        return unless env['CONTENT_TYPE'] # no request body
        return if env['CONTENT_TYPE'] == 'application/vnd.api+json' # jsonapi
        return unless contains_media_type_params?(env['CONTENT_TYPE']) # no jsonapi w params
        
        raise_error(415,
                    'Clients MUST send all JSON:API data in request documents with the header ' \
                    'Content-Type: application/vnd.api+json without any media type parameters.')
      end

      # Checks to see if the JSON:API media type is included in the Accept header, and if
      #   it is, whether it contains media type parameters.
      # @param (see #compliant?)
      def self.check_accept(env)
        return unless env['HTTP_ACCEPT']
        accept_arr = env['HTTP_ACCEPT'].split(',')
        return if accept_arr.include? 'application/vnd.api+json'
        
        found_jsonapi_media_type_w_params = false
        accept_arr.each do |val|
          found_jsonapi_media_type_w_params ||= contains_media_type_params?(val)
        end
        return unless found_jsonapi_media_type_w_params

        raise_error(406,
                    'Clients that include the JSON:API media type in their Accept header MUST ' \
                    'specify the media type there at least once without any media type parameters.')
      end

      def self.contains_media_type_params?(header_value)
        header_value.match(%r{\Aapplication/vnd\.api\+json\s?;})
      end

      # @param msg [String]  The message to raise InvalidHeader with.
      def self.raise_error(status_code = 400, msg)
        raise InvalidHeader.new(status_code), msg
      end

      private_class_method :check_content_type, :check_accept, :raise_error
    end
  end
end
