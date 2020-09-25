module JSONAPI
  class Request
    attr_accessor :path, :protocol, :host, :port, :params,
                  :pagination, :headers, :method, :document, :field_sets

    def initialize(env, params, pagination, field_sets, headers, document)
      @path = env['REQUEST_PATH']
      @protocol = env['REQUEST_METHOD']
      @host = env['SERVER_NAME']
      @port = env['SERVER_PORT']
      @params = params
      @pagination = pagination
      @field_sets = field_sets
      @headers = headers
      @document = document
    end
  end
end
