# frozen_string_literal: true

require 'rack/jsonapi/collection'

module JSONAPI
  
  # Collection of fields related to specific resource objects
  class Fieldset < JSONAPI::Collection

    # @param_
    def initialize(res_field_arr = [])
      super(res_field_arr, &:name)
    end


  end
end
