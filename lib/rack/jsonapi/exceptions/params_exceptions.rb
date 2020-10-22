# frozen_string_literal: true

require 'rack/jsonapi/exceptions/naming_exceptions'

module JSONAPI
  module Exceptions
    
    # Validates that the Query Parameters comply with the JSONAPI specification
    module ParamExceptions
      
      # A more specific Standard Error to raise
      class InvalidParameter < StandardError
      end

      # Checks to see if the query paramaters conform to the JSONAPI spec and raises InvalidParameter
      #   if any parts are found to be non compliant
      # @query_param rack_req_params [Hash] The hash of the query parameters given by Rack::Request
      def self.check_compliance!(rack_req_params)
        check_implemenation_specific_names!(rack_req_params)
      end

      # Check if implementation specific query params observe the jsonapi spec
      # @query_param (see #check_compliance!)
      def self.check_implemenation_specific_names!(rack_req_params)
        impl_spec_names = rack_req_params.keys - ['include', 'fields', 'page', 'sort', 'filter']
        impl_spec_names.each do |name|
          next if NamingExceptions.check_member_constraints(name).nil? && NamingExceptions.check_additional_constraints(name).nil?
          
          raise_error!(
            'Implementation specific query parameters MUST adhere to the same constraints ' \
            "as member names (a-z, A-Z, 0-9) and ('-', '_') allowed in the middle, with the " \
            "additional requirement - they MUST contain at least one non a-z character."
          )  
        end
        nil
      end

      # @query_param msg [String] the message to raise InvalidParameter with.
      def self.raise_error!(msg)
        raise InvalidParameter, msg
      end

      private_class_method :check_implemenation_specific_names!, :raise_error!
    end
  end
end
