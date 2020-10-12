# frozen_string_literal: true

module JSONAPI
  
  # Namespace for the gem's Exceptions
  module Exceptions
    
    # Validates that the Query Parameters comply with the JSONAPI specification
    module ParamExceptions
      # Implementation specific query parameters MUST adhere to the same constraints
      # as member names with the additional requirement that they MUST contain at 
      # least one non a-z character (U+0061 to U+007A). It is RECOMMENDED that a 
      # U+002D HYPHEN-MINUS, '-', U+005F LOW LINE, '_', or capital letter is used 
      # (e.g. camelCasing).

      
    end
    
    # Validates that Headers comply with the JSONAPI specification
    module HeaderExceptions end
    
    # Validates that the request or response document complies with the JSONAPI specification  
    module DocumentExceptions end
  end
end
