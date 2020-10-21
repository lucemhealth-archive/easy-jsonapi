# frozen_string_literal: true

module JSONAPI
  module Exceptions
    
    # Checking for JSONAPI naming rules compliance
    module NamingExceptions
      
      # JSONAPI member names can only contain a-z, A-Z, 0-9, '-', '_', and the last two cannot be used
      #   at the start or end of a member name.
      # @param name [String] The string to check for member name rule compliance
      # @returns 
      def self.check_member_constraints(name)
        name = name.to_s
        return 'Member names MUST contain at least one character' if name == ''
        unless (name =~ /[^a-zA-Z0-9_-]/).nil?
          return 'Member names MUST contain only the allowed characters: ' \
                  "a-z, A-Z, 0-9, '-', '_'"
        end
        unless (name[0] =~ /[-_]/).nil? && (name[-1] =~ /[-_]/).nil?
          return 'Member names MUST start and end with a globally allowed character'
        end
        nil
      end

      # JSONAPI implementation specific query parameters follow the same constraints as member names
      #   with the additional requirement that they must also contain at least one non a-z character.
      # @param name [String] The string to check for 
      def self.check_additional_constraints(name)
        name = name.to_s
        return nil unless (name =~ /[^a-z]/).nil?
        'Implementation specific query parameters MUST scontain at least one non a-z character'
      end
    end
  end
end
