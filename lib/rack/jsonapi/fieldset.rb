# frozen_string_literal: true

require 'rack/jsonapi/collection'

module JSONAPI
  
  # Collection of fields related to specific resource objects
  class Fieldset < JSONAPI::Collection

    # @param res_field_arr [Array<JSONAPI::Document::Resource::Field>]
    #   A fieldset is a collection of Resource Fields
    def initialize(res_field_arr = [])
      super(res_field_arr, &:name)
    end


  end
end
