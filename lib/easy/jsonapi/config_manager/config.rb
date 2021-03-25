# frozen_string_literal: true

module JSONAPI
  class ConfigManager

    # User configurations for the gem
    class Config

      attr_reader :required_document_members, :required_headers, :required_query_params,
                  :allow_client_ids
      
      def initialize
        @allow_client_ids = false
        @default = true
      end
      
      # Performancewise, configs are all initialized as a startup cost, to change them you need to
      #   restart the server. As a result of this, the #default? is used to process a request 
      #   faster if user-defined configs do not need to be checked when screening http requests.
      #   Because @default is set to false upon config assignment (see #method missing in Config),
      #   this allows the a user to potentially make the middleware screening less performant than necessary
      #   by assigning config values to the default values, or assigning values to something not default,
      #   and then assigning config values to the default again. If used as intended, however, this should make
      #   the middleware screening faster.
      # @return [TrueClass | FalseClass]
      def default?
        @default
      end

      private

      READER_METHODS = %i[required_document_members required_headers required_query_params allow_client_ids].freeze

      # Only used if implementing Item directly.
      #   dynamically creates accessor methods for instance variables
      #   created in the initialize
      def method_missing(method_name, *args, &block)
        super unless READER_METHODS.include?(method_name.to_s[0..-2].to_sym)
        instance_variable_set("@#{method_name}"[0..-2].to_sym, args[0])
        @default = false 
      end

      # Needed when using #method_missing
      def respond_to_missing?(method_name, *args)
        methods.include?(method_name) || super
      end
    end
  end
end
