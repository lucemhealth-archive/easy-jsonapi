require 'jsonapi/document'
# require 'jsonapi/to/objec/resource'
# require 'jsonapi/to/objec/relationship'

##
# This module is a namespace that encapuslates all jsonapi-to-object objects

module JSONAPI
  def 


  module Params
    def parse_request!(req)
      pp "parsing request params"
    end
  end

  module Header
    def parse_request!(req)
      pp "parsing request headers"
    end
  end

  module Document
    def parse_request!(req)
      pp "parsing request document"
    end
  end
    # @see JSONAPI::Request::Parser::Document.validate!
    self.def parse_response!(document)
      Parser::Document.parse!(document)
    end
  
    # # @see JSONAPI::Request::Parser::Resource.validate!
    # self.def parse_resource!(document)
    #   Parser::Resource.parse!(document)
    # end
  
    # # @see JSONAPI::Request::Parser::Relationship.validate!
    # self.def parse_relationship!(document)
    #   Parser::Relationship.parse!(document)
    # end
end