# frozen_string_literal: true

require 'rack/jsonapi/version'
require 'rack/jsonapi/parser'

# Only used if error checking with header exceptions
require 'rack/jsonapi/exceptions'
require 'rack/jsonapi/exceptions/headers_exceptions'

module JSONAPI

  # The middleware of the gem and also the contact point between the
  # the gem and the rack application using it
  # @!Visibility private
  class Middleware

    # @param app The Rack Application
    def initialize(app)
      @app = app
    end
    
    # @param env The rack envirornment hash
    def call(env)

      # Parse Request and Initiate Request Object if JSONAPI Request
      # add a if statement to skip middleware if jsonapi document isn't included
      jsonapi_document = includes_jsonapi_document?(env)
      if jsonapi_document || !configured_to_skip?
        jsonapi_request = JSONAPI::Parser.parse_request!(env, jsonapi_document)
        pp "jsonapi_request constructed? #{jsonapi_request.nil?}"
        send_to_rack_app(jsonapi_request, 'jsonapi_request')
      end

      @app.call(env)
    end

    def configured_to_skip?
      # Add logic that scans a config file to see if the user wants to skip the middleware if a jsonapi is not included with the request
      # For now assume not configured to skip
      false
    end

    # Determines whether there is a request body, and whether the Content-Type is jsonapi compliant
    # @param (see #call)
    # @returns [TrueClass | FalseClass] whether 
    def includes_jsonapi_document?(env)
      JSONAPI::Exceptions::HeadersExceptions.check_compliance!(env).nil?
      env['CONTENT_TYPE'] == 'application/vnd.api+json'
    end
    
    # Provides the rack application access to an instance variable
    # @param var The variable being provided
    # @param str_var The name of the instance variable and accessor method
    def send_to_rack_app(var, str_var)
      application = find_app_class(@app, @app)
      
      application.send(:define_method, str_var) do
        instance_variable_set("@#{str_var}", var)
        instance_variable_get("@#{str_var}")
      end
    end
  
    # Locates the rack application (sinatra or rails included) that
    #   that call sends an instance variable too
    # @param current The current middleware or rack app that is being referenced
    # @param last The previous middleware referenced.
    # @todo Raise an error if current.class == NilClass and current.class == last.class
    def find_app_class(cur, last)
      return last.class if cur.class == NilClass
      return cur.class unless cur.instance_variables.include? :@app
      find_app_class(cur.instance_variable_get(:@app), cur)
    end
    
  end
end
