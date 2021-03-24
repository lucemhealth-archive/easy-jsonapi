# frozen_string_literal: true

# Needed so that config.ru can get JSONAPI::Middleware
require 'easy/jsonapi/middleware'
require 'easy/jsonapi/parser'
require 'easy/jsonapi/response'

# This module is the top level namespace for the curatess jsonapi middleware gem
#
# @author Joshua DeMoss
# @see https://app.lucidchart.com/invitations/accept/e24c2cfe-78f1-4192-8e88-6dbc4454a5ea UML Class Diagram
module JSONAPI
end
