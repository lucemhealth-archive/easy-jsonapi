# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection'
require 'rack/jsonapi/name_value_pair'
require 'rack/jsonapi/exceptions/query_params_exceptions'
require 'rack/jsonapi/utility'


module JSONAPI
  class Request
    class QueryParamCollection < JSONAPI::NameValuePairCollection
      # A generic name=value query parameter
      class QueryParam < JSONAPI::NameValuePair

        # @param name [String] The name of the parameter
        # @param value [String | Array<String>] The value of the parameter
        def initialize(name, value)
          if instance_of?(QueryParam)
            JSONAPI::Exceptions::QueryParamsExceptions.check_param_name(name)
          end
          value = value.split(',') if value.is_a? String
          super(name, value)
        end
  
        # Update the query_param value, turning value into an array if it was given as a string
        # @param new_value [String, Array<String>] The new value of the Parameter
        def value=(new_value)
          new_value = new_value.split(',') if new_value.is_a? String
          super(new_value)
        end
        
        # Represents a parameter as a string
        def to_s
          "#{name}=#{JSONAPI::Utility.to_string_collection(value, delimiter: ',')}"
        end

        # @raise RuntimeError Cannot change the name of a QueryParam object
        def name=(_)
          raise 'Cannot change the name of QueryParam Objects'
        end
      end
    end
  end
end

# include=author,comments-likers,comments.likes
# author comments-likers comments.likes
