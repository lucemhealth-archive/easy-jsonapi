# frozen_string_literal: true

require 'rack/jsonapi/exceptions'

module JSONAPI
  # Used to validate the serialized response before returned to a client
  module Response

    # @param body [Hash] The ruby hash mimicking jsonapi to check for compliance
    # @return [Nilclass] if no errors are found
    # @raise [InvalidDocument | InvalidHeader] depending on what errors were found
    def self.validate(body, headers)
      validate_headers(headers)
      validate_body(body)
    end
    
    # @param (see #validate)
    # @return (see #validate)
    # @raise InvalidDocument if document found to be non compliant
    def self.validate_body(body)
      JSONAPI::Exceptions::DocumentExceptions.check_compliance(body, is_a_request: false)
    end
    
    # @param (see #validate)
    # @return (see #validate)
    # @raise InvalidHeader if header found to be non compliant
    def self.validate_headers(headers)
      JSONAPI::Exceptions::HeadersExceptions.check_compliance(headers.transform_keys(&:upcase))
    end
  end
end
