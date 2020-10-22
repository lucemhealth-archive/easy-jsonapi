# frozen_string_literal: true

module JSONAPI
  module Exceptions
    # Validates that Headers comply with the JSONAPI specification
    module HeadersExceptions 
      class InvalidHeader < StandardError
      end

      # @query_param env [Hash] The rack environment variable
      def self.check_compliance!(env)
        check_content_type!(env)
        check_accept!(env)
      end

      # Checks the content type of the request to see if it is jsonapi.
      #   If it is jsonapi or if it is a different media type it won't raise an error.
      #   It will raise an error if it is jsonapi and includes parameters.
      # @query_param (see #compliant?)
      # @returns nil Returns nil if no error found
      # @raises InvalidHeader if it is jsonapi with parameters
      def self.check_content_type!(env)
        return if env['CONTENT_TYPE'].nil?
        return if env['CONTENT_TYPE'] == 'application/vnd.api+json'
        return if (env['CONTENT_TYPE'] =~ %r{\Aapplication/vnd\.api\+json\s?;}).nil?
        
        raise_error!(
          'Clients MUST send all JSON:API data in request documents with the header ' \
          'Content-Type: application/vnd.api+json without any media type parameters.'
        )
      end

      # Checks to see if the JSON:API media type is included in the Accept header, and if
      #   it is, whether it contains media type parameters.
      # @query_param (see #compliant?)
      def self.check_accept!(env)
        jsonapi_doc_w_params = false
        accept_arr = env['HTTP_ACCEPT'].split(',')
        
        return if accept_arr.include? 'application/vnd.api+json'
        accept_arr.each do |val|
          jsonapi_doc_w_params ||= val.match(%r{\Aapplication/vnd\.api\+json\s?;})
        end
        return unless jsonapi_doc_w_params

        raise_error!(
          'Clients that include the JSON:API media type in their Accept header MUST ' \
          'specify the media type there at least once without any media type parameters.'
        )
      end

      # @query_param msg [String] the message to raise InvalidHeader with.
      def self.raise_error!(msg)
        raise InvalidHeader, msg
      end

      private_class_method :check_content_type!, :check_accept!, :raise_error!
    end
  end
end
