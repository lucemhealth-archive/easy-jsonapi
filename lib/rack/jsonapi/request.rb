# frozen_string_literal: true

module JSONAPI

  # Contains all objects relating to a HTTP request
  class Request
    attr_accessor :path, :protocol, :host, :port, :query_string, :params, :headers, :document

    # @query_param env The rack envirornment hash
    # @query_param query_param_collection [QueryParamCollection] The already initialized QueryParamCollection class
    # @query_param header_collection [HeaderCollection] The already initialized HeaderCollection class
    # @query_param document [Document] The already initialized Document class
    def initialize(env, query_param_collection, header_collection, document)
      # from env hash
      @path = env['REQUEST_PATH']
      @protocol = env['REQUEST_METHOD']
      @host = env['SERVER_NAME']
      @port = env['SERVER_PORT']
      @query_string = env['QUERY_STRING']

      # parsed objects
      @params = query_param_collection
      @headers = header_collection
      @document = document
    end

  end
end
