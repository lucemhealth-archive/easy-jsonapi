# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/document/error/error_member'

module JSONAPI
  class Document
    # An individual errors member in a jsonapi's document top level 'errors' member
    class Error < JSONAPI::NameValuePairCollection

      def initialize(err_members = [])
        super(err_members, JSONAPI::Document::Error::ErrorMember)
      end

      # collection methods provided by super
      
      # TODO: Check if we want dynamic accessor methods.
      # def method_missing(method_name, *args, &block)
      #   super unless include? method_name
      #   if should_set?(method_name)
      #     set(method_name[..-2].to_sym, args[0]) 
      #   else
      #     get(method_name)
      #   end
      # end

      # def respond_to_missing?(method_name, *)
      #   include?(method_name) || super
      # end

      # private

      # def should_set?(method_name)
      #   method_name.to_s[-1] == '=' && include?(method_name[..-2].to_sym)
      # end

    end
  end
end
