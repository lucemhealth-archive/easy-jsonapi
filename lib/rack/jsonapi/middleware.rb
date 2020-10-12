# frozen_string_literal: true

require 'rack/jsonapi/version'
require 'rack/jsonapi/parser'

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
      if jsonapi_request?(env)
        jsonapi_request = JSONAPI::Parser.parse_request!(env)
        application = find_app_class(@app, @app)
  
        application.send(:define_method, 'jsonapi_request') do
          instance_variable_set('@jsonapi_request', jsonapi_request)
          @jsonapi_request
        end
      end

      @app.call(env)
    end

    # Determines whether the middleware should be used
    def jsonapi_request?(env)
      return false if env.nil?
      m = env['CONTENT_TYPE'].match(%r{application/vnd.*\.api\+json})
      !m.nil?
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
