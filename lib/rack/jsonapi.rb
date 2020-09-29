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
      # # Parse Request and Initiate Request Object
      # @jsonapi_request = JSONAPI::Parser.parse_request!(env)
      @jsonapi_request = 'this is the request'

      cur = @app
      is_a_rack_app = true
      while (is_a_rack_app)
        cur = cur.instance_variable_get(:@app)
        # is_a_rack_app = CHECKING IF CUR IS A MIDDLEWARE
      end

      cur.instance_variable_set('@jsonapi_request', @jsonapi_request)

      @app.call(env)
    end
  end
end
