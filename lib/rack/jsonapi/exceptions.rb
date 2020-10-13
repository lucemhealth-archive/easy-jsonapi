# frozen_string_literal: true

module JSONAPI
  
  # Namespace for the gem's Exceptions
  module Exceptions

    # Raises an error with an error message. Used by sub modules
    # @param error_class [StandardError] The type of error raised
    # @param error_message [String] The message describing the error
    def self.raise_error!(error_class, error_message)
      raise error_class, error_message
    end

    # Validates that the Query Parameters comply with the JSONAPI specification
    module ParamExceptions
    end
    
    # Validates that Headers comply with the JSONAPI specification
    module HeadersExceptions
    end

    # Validates that the request or response document complies with the JSONAPI specification  
    module DocumentExceptions
    end

  end
end
