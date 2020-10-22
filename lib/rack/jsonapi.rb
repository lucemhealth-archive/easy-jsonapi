# frozen_string_literal: true

require 'rack/jsonapi/middleware'

# This module is the top level namespace for the curatess jsonapi middleware gem
#
# @author Joshua DeMoss
# @see https://app.lucidchart.com/invitations/accept/e24c2cfe-78f1-4192-8e88-6dbc4454a5ea UML Class Diagram
module JSONAPI

  # An abstract collection of Item objects
  class Collection
    class HeaderCollection end
    class ParamCollection end
  end
  
  # The body of a request that conforms to the jsonapi spec
  class Document
    # The different sections of a JSONAPI Document
    class Included end
    class Meta end
    class ResourceId end
    class Resource end
  end
  
  # Namespace for the gem's Exceptions
  module Exceptions end
  
  # An abstract Item -- contains 0 to * key-value relationships
  class Item 
    # A generic query parameter
    class QueryParam 
      # Specific Query Parameters:
      class Fieldset end
      class Filter end  
      class Include end
      class Page end
      class Sort end
    end
  end
  
  # Intercepts rack request and initializes the Request object
  class Middleware end
  
  # Namespace for the gem's Parsing Logic
  module Parser
    # Parses Request body and initializes Document class
    module DocumentParser end
    # Parses request headers and initializes HeaderCollection class
    module HeadersParser end
    # Parses request query parameters and initializes ParamCollection class
    module RackReqParamsParser end
  end
  
  # Contact point for user -- accesses all classes that are related to a JSONAPI request
  class Request end
end
