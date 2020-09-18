
module JSONAPI
    class Request
        attr_accessor :path, :protocol, :host, :port, :params,
                        :pagination, :headers, :method, :document

        def initialize(req)
            pp "Initialized"
            # Parser::Document.parse!(req)
        end

    end
end