# frozen_string_literal: true

module JSONAPI
  module Exceptions
    
    # Checking for JSONAPI naming rules compliance
    module NamingExceptions
      
      # JSONAPI member names can only contain a-z, A-Z, 0-9, '-', '_', and the last two cannot be used
      #   at the start or end of a member name.
      # @param name [String] The string to check for member name rule compliance
      def self.follows_member_constraints?(name)
        (name =~ /[^a-zA-Z0-9_-]/).nil? && (name[0] =~ /[-_]/).nil? && (name[-1] =~ /[-_]/).nil?
      end

      # JSONAPI implementation specific query parameters follow the same constraints as member names
      #   with the additional requirement that they must also contain at least one non a-z character.
      # @param name [String] The string to check for 
      def self.follows_additional_constraints?(name)
        !(name =~ /[^a-z]/).nil?
      end
      
    end
  end
end
