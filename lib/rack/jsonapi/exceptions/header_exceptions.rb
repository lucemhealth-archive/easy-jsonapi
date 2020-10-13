# frozen_string_literal: true

require 'rack/jsonapi/exceptions'

module JSONAPI
  module Exceptions
    # Validates that Headers comply with the JSONAPI specification
    module HeaderExceptions 
      class InvalidHeader < StandardError
      end
    end
  end
end
