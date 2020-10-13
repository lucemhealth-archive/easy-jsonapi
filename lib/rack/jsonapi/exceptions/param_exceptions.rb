# frozen_string_literal: true

require 'rack/jsonapi/exceptions'

module JSONAPI
  module Exceptions
    
    # Validates that the Query Parameters comply with the JSONAPI specification
    module ParamExceptions
      
      class InvalidParameter < StandardError
      end
      # Implementation specific query parameters MUST adhere to the same constraints
      # as member names with the additional requirement that they MUST contain at 
      # least one non a-z character (U+0061 to U+007A). It is RECOMMENDED that a 
      # U+002D HYPHEN-MINUS, '-', U+005F LOW LINE, '_', or capital letter is used 
      # (e.g. camelCasing).
      
    end
    
  end
end
