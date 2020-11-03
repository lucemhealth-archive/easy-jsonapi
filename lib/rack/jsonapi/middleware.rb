# frozen_string_literal: true

require 'rack/jsonapi/parser'

module JSONAPI

  # The middleware of the gem and also the contact point between the
  # the gem and the rack application using it
  class Middleware

    # @param app The Rack Application
    def initialize(app)
      @app = app
    end
    
    # @param env The rack envirornment hash
    def call(env)

      jsonapi_document = includes_jsonapi_document?(env)
      if jsonapi_document || !configured_to_skip?
        jsonapi_request = JSONAPI::Parser.parse_request!(env, jsonapi_doc_included: jsonapi_document)
        send_to_rack_app(jsonapi_request, 'jsonapi_request')
      end

      @app.call(env)
    end

    private

    # Reads a config file for user preferences

    # Checks if a user would prefer to skip request initialization if a jsonapi document
    #   is not included.
    def configured_to_skip?
      # TODO: Add logic that scans a config file to see if the user wants to skip the middleware if a jsonapi is not included with the request
      # For now assume not configured to skip
      false
    end

    # Determines whether there is a request body, and whether the Content-Type is jsonapi compliant
    # @param (see #call)
    # @return [TrueClass | FalseClass] whether 
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
      nil
    end
  
    # Locates the rack application (sinatra or rails included) that
    #   that call sends an instance variable too
    # @param cur The current middleware or rack app that is being referenced
    # @param last The previous middleware referenced.
    # @todo Raise an error if current.class == NilClass and current.class == last.class
    def find_app_class(cur, last)
      return last.class if cur.class == NilClass
      return cur.class unless cur.instance_variables.include? :@app
      find_app_class(cur.instance_variable_get(:@app), cur)
    end
    
  end
end
