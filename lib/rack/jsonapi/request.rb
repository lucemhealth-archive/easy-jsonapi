# frozen_string_literal: true

module JSONAPI

  # Contains all objects relating to a HTTP request
  class Request
    attr_accessor :path, :protocol, :host, :port, :query_string, :params, :headers, :document

    # @param env The rack envirornment hash
    # @param param_collection [ParamCollection] The already initialized ParamCollection class
    # @param header_collection [HeaderCollection] The already initialized HeaderCollection class
    # @param document [Document] The already initialized Document class
    def initialize(env, param_collection, header_collection, document)
      @path = env['REQUEST_PATH']
      @protocol = env['REQUEST_METHOD']
      @host = env['SERVER_NAME']
      @port = env['SERVER_PORT']
      @query_string = env['QUERY_STRING']

      @params = param_collection
      @headers = header_collection
      @document = document
    end

  end
end
