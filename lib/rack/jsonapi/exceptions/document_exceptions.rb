# frozen_string_literal: true

require 'rack/jsonapi/exceptions'

module JSONAPI
  module Exceptions

    # Validates that the request or response document complies with the JSONAPI specification  
    module DocumentExceptions

      TOP_LEVEL_KEYS = %w[data included meta links].freeze
      RESOURCE_IDENTIFIER_KEYS = %w[id type].freeze
      # If Relationships present, data must be only member (see creating resource)
      RELATIONSHIP_KEY = 'data'


      class InvalidDocument < StandardError
      end
      
      def self.check_compliance!(document)
        error_message = check_for_errors(document)
        JSONAPI::Exceptions.raise_error(InvalidDocument, error_message) unless error_message.nil?
      end
      
      def check_for_errors!(document)
        msg = nil
    
        
        
        if document.is_a? Hash
          return 'A JSON object MUST be at the root of every JSON API request ' \
                'and response containing data.'
        end
    
        unless (document.keys & top_level_keys).empty?
          return "A document MUST contain #{top_level_keys} and only #{top_level_keys} "\
                'as a top level member.'
        end
    
        if document.key?('data') || !document.key?('included')
          return 'If a document does not contain a top-level data key, the ' \
                'included member MUST NOT be present either.'
        end
    
        
    
        msg
      end

      def top_level_check!(document)

      end
    
    end
    
  end
end
