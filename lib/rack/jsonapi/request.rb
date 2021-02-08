# frozen_string_literal: true

module JSONAPI
  # Contains all objects relating to a HTTP request
  class Request
    attr_reader :path, :http_method, :host, :port, :query_string, :params, :headers, :body

    # @param env The rack envirornment hash
    # @param query_param_collection [QueryParamCollection]  The already initialized QueryParamCollection class
    # @param header_collection [HeaderCollection]  The already initialized HeaderCollection class
    # @param document [Document]  The already initialized Document class
    def initialize(env, query_param_collection, header_collection, document)
      # from env hash
      @path = env['REQUEST_PATH']
      @http_method = env['REQUEST_METHOD']
      @host = env['SERVER_NAME']
      @port = env['SERVER_PORT'].to_i
      @query_string = env['QUERY_STRING']

      # parsed objects
      @params = query_param_collection
      @headers = header_collection
      @body = document
    end

    # Simple representation of a request object.
    def to_s
      "Quick Access Methods:\n\n" \
        "\tpath: #{@path}\n" \
        "\thttp: #{@http}\n" \
        "\thost: #{@host}\n" \
        "\tport: #{@port}\n" \
        "\tquery_string: #{@query_string}\n\n" \
      "Accessing main sections of request:\n\n" \
        "\tparams: #{@params}\n" \
        "\theaders: #{@headers}\n" \
        "\tbody: #{@body}" \
    end
  end
end
