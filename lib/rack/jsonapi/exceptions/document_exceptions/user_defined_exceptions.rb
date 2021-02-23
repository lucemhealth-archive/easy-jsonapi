# frozen_string_literal: true

require 'rack/jsonapi/exceptions/document_exceptions'

module JSONAPI
  module Exceptions
    module DocumentExceptions

      # Allows a user of the gem to define extra requirements they want the middlewar to check for.
      module UserDefinedExceptions

        class << self

          
          # Indicates the members that are required in order for the
          #   JSONAPI Request to be considered valid
          #   Ex: 
          #     { 
          #       data:
          #         [
          #           { 
          #             type: nil, 
          #              attributes: { a1: nil, a2: nil }
          #           }
          #         ],
          #       meta: 
          #         { 
          #           m1: nil
          #         }
          #     }
          # @param document [Hash] The hash representation of the json body
          # @param req_mems[Hash] The hash representation of the user-defined required json members.
          def check_additional_required_members(document, req_mems)
            unless req_mems.nil?
              ensure!(document.instance_of?(req_mems.class), "User-defined required members hash does not mimic structure of json document: #{document}")
            end
            
            case req_mems
            when nil
              nil
            when Hash
              req_mems.each do |k, v|
                ensure!(document[k], "Document is missing one of the user-defined required keys: #{k}")
                check_additional_required_members(document[k], v)
              end
            when Array
              document.each do |m|
                check_additional_required_members(m, req_mems.first)
              end
            end
            nil
          end

          private
          
          # Helper function to raise InvalidDocument errors
          # @param condition The condition to evaluate
          # @param error_message [String]  The message to raise InvalidDocument with
          # @raise InvalidDocument
          def ensure!(condition, error_message)
            raise InvalidDocument, error_message unless condition
          end
        end
      end
    end
  end
end
