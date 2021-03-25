# frozen_string_literal: true

require 'easy/jsonapi/exceptions'

module JSONAPI
  # Used to validate the serialized response before returned to a client
  module Response
    # TODO: Add config_manager options for out bound serialization validation

    # @param headers [Hash] The hash of response headers.
    # @param body [Hash | String] The ruby hash mimicking jsonapi or
    #   a JSON document to check for compliance
    # @return [Nilclass] if no errors are found
    # @raise [InvalidDocument | InvalidHeader] depending on what errors were found
    def self.validate(headers, body)
      # TODO: Spec checks based on collections which can be refered from the location header
      #   returned by the server
      JSONAPI::Exceptions::HeadersExceptions.check_compliance(headers.transform_keys(&:to_s).transform_keys(&:upcase))
      JSONAPI::Exceptions::DocumentExceptions.check_compliance(body)
    end
  end
end
