# frozen_string_literal: true

module JSONAPI
  
  # User configurations for the gem
  class Config

    attr_accessor :required_document_members, :required_headers, :required_query_params,
                  :allow_client_ids

    def initialize
      @allow_client_ids = false
    end
  end
end
