# frozen_string_literal: true

require 'rack/jsonapi/exceptions/naming_exceptions'

module JSONAPI
  module Exceptions
    
    # Validates that the Query Parameters comply with the JSONAPI specification
    module QueryParamsExceptions
      
      # A more specific Standard Error to raise
      class InvalidQueryParameter < StandardError
      end

      # The jsonapi specific query parameters.
      SPECIAL_QUERY_PARAMS = %i[include fields page sort filter].freeze

      # Checks to see if the query paramaters conform to the JSONAPI spec and raises InvalidQueryParameter
      #   if any parts are found to be non compliant
      # @param rack_req_params [Hash]  The hash of the query parameters given by Rack::Request
      def self.check_compliance(rack_req_params)
        impl_spec_names = rack_req_params.keys - %w[include fields page sort filter]
        impl_spec_names.each do |name|
          check_param_name(name)
        end
        nil
      end

      # Checks an implementation specific param name to see if it complies to the spec.
      def self.check_param_name(name)
        return if NamingExceptions.check_member_constraints(name).nil? && NamingExceptions.check_additional_constraints(name).nil?
        raise_error(
          'Implementation specific query parameters MUST adhere to the same constraints ' \
          "as member names (a-z, A-Z, 0-9) and ('-', '_') allowed in the middle, with the " \
          "additional requirement - they MUST contain at least one non a-z character."
        )
      end

      # @param msg [String]  The message to raise InvalidQueryParameter with.
      def self.raise_error(msg)
        raise InvalidQueryParameter, msg
      end

      private_class_method :raise_error
    end
  end
end
