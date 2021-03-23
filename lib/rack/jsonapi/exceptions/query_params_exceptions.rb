# frozen_string_literal: true

require 'rack/jsonapi/exceptions/naming_exceptions'
require 'rack/jsonapi/exceptions/user_defined_exceptions'

module JSONAPI
  module Exceptions
    
    # Validates that the Query Parameters comply with the JSONAPI specification
    module QueryParamsExceptions
      
      # A more specific Standard Error to raise
      class InvalidQueryParameter < StandardError
        attr_accessor :status_code

        # Init w a status code, so that it can be accessed when rescuing an exception
        def initialize(status_code)
          @status_code = status_code
          super
        end
      end

      # The jsonapi specific query parameters.
      SPECIAL_QUERY_PARAMS = %i[include fields page sort filter].freeze

      # Checks to see if the query paramaters conform to the JSONAPI spec and raises InvalidQueryParameter
      #   if any parts are found to be non compliant
      # @param rack_req_params [Hash]  The hash of the query parameters given by Rack::Request
      def self.check_compliance(rack_req_params, config_manager = nil, opts = {})
        impl_spec_names = rack_req_params.keys - %w[include fields page sort filter]
        impl_spec_names.each do |name|
          check_param_name(name)
        end
        
        err_msg = JSONAPI::Exceptions::UserDefinedExceptions.check_user_query_param_requirements(rack_req_params, config_manager, opts)
        return err_msg unless err_msg.nil?

        nil
      end

      # Checks an implementation specific param name to see if it complies to the spec.
      def self.check_param_name(name)
        should_return =  
          NamingExceptions.check_member_constraints(name).nil? && \
          NamingExceptions.check_additional_constraints(name).nil? && \
          !name.include?('-')
        return if should_return
        
        raise_error(
          'Implementation specific query parameters MUST adhere to the same constraints ' \
          'as member names. Allowed characters are: a-z, A-Z, 0-9 for beginning, middle, or end characters, ' \
          "and '_' is allowed for middle characters. (While the JSON:API spec also allows '-', it is not " \
          'recommended, and thus is prohibited in this implementation). ' \
          'Implementation specific query members MUST contain at least one non a-z character as well. ' \
          "Param name given: \"#{name}\""
        )
      end

      # @param msg [String]  The message to raise InvalidQueryParameter with.
      def self.raise_error(msg, status_code = 400)
        raise InvalidQueryParameter.new(status_code), msg
      end

      private_class_method :raise_error
    end
  end
end
