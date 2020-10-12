# frozen_string_literal: true

module JSONAPI
  
  # Collection of fields/attributes related to specific resource objects
  class Fieldset

    def initialize(param_field_arr)
      @fields = param_field_arr
    end
  end
end
