# frozen_string_literal: true

require 'rack/jsonapi/version'
require 'rack/jsonapi/parser'

# This module is the top level namespace for the curatess jsonapi middleware gem
#
# @author Joshua DeMoss
# @see https://app.lucidchart.com/invitations/accept/e24c2cfe-78f1-4192-8e88-6dbc4454a5ea UML Class Diagram
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
      # Parse Request and Initiate Request Object
      jsonapi_request = JSONAPI::Parser.parse_request!(env)
      application = find_application_class(@app, @app)

      application.send(:define_method, 'jsonapi_request') do
        instance_variable_set('@jsonapi_request', jsonapi_request)
        @jsonapi_request
      end

      @app.call(env)
    end

    def jsaonapi_request?(env)
      m = env['HTTP_ACCEPT'].match(%r{application/vnd.*\.api\+json})
      !m.nil?
    end

    # Used to locate the rack application (sinatra or rails included) that
    #   that call sends an instance variable too
    # @param current The current middleware or rack app that is being referenced
    # @param last The previous middleware referenced.
    # @todo Raise an error if current.class == NilClass and current.class == last.class
    def find_application_class(current, last)
      return last.class if current.class == NilClass
      return current.class unless current.instance_variables.include? :@app
      find_application_class(current.instance_variable_get(:@app), current)
    end
  end
end
