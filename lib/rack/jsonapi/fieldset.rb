# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'

module JSONAPI
  
  # Collection of fields related to specific resource objects
  class Fieldset < JSONAPI::NameValuePairCollection

    # @param res_field_arr [Array<JSONAPI::Document::Resource::Field>]
    #   A fieldset is a collection of Resource Fields
    def initialize(res_field_arr = [])
      super(res_field_arr, JSONAPI::Document::Resource::Field)
    end
    
    # Represent a fieldset as an array of fields
    # def to_s
    #   to_return = '['
    #   is_first = true
    #   each do |field|
    #     if is_first
    #       to_return += field.to_s
    #       is_first = false
    #     else
    #       to_return += ", #{field}"
    #     end
    #   end
    #   to_return += ']'
    # end

    def to_s
      field_str_arr = map(&:to_s)
      field_str_arr.join(',')
    end

  end
end
