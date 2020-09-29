# frozen_string_literal: true

module JSONAPI

  # Contains all objects relating to a HTTP request
  class Request
    attr_accessor :path, :protocol, :host, :port, :params, :query_string,
                  :pagination, :headers, :method, :document, :field_sets

    # @param env The rack envirornment hash
    # @param params [Params] The already initialized Params class
    # @param pagination [Pagination] The already initialized Pagination class
    # @param field_sets [FieldSets] The alread initialized FieldSets class
    # @param headers [Headers] The already initialized Headers class
    # @param Document [Document] The already initialized Document class
    def initialize(env, params, pagination, field_sets, headers, document)
      @path = env['REQUEST_PATH']
      @protocol = env['REQUEST_METHOD']
      @host = env['SERVER_NAME']
      @port = env['SERVER_PORT']
      @query_string = env['QUERY_STRING']
      @params = params
      @pagination = pagination
      @field_sets = field_sets
      @headers = headers
      @document = document
    end
  end
end
