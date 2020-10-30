# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair'
require 'rack/jsonapi/request'
require 'rack/jsonapi/request/query_param_collection'
require 'rack/jsonapi/exceptions'
require 'rack/jsonapi/exceptions/query_params_exceptions'

module JSONAPI
  class Request
    class QueryParamCollection
      # A generic name->value query parameter
      class QueryParam < JSONAPI::NameValuePair
        
        # @query_param name The name of the parameter
        # @query_param value The value of the parameter
        def initialize(name, value)
          if self.class == QueryParam
            JSONAPI::Exceptions::QueryParamsExceptions.check_param_name!(name)
          end
          value = value.split(',') if value.is_a? String
          super(name, value)
        end
  
        # name provided by super
        # name= provided by super
        # value provided by super
    
        # Update the query_param value, turning value into an array if it was given as a string
        # @query_param new_val [String, Array<String>] The new value of the Parameter
        def value=(new_val)
          new_val = new_val.split(',') if new_val.is_a? String
          super(new_val)
        end
        
        # Represents a parameter as a string
        def to_s
          str_val = @item[:value].join(',') if @item[:value].is_a? Array
          "#{name} => { \"#{name}\": \"#{str_val}\" }"
        end
      end
    end
  end
end
