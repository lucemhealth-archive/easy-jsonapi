# frozen_string_literal: true

require 'easy/jsonapi/request'
require 'easy/jsonapi/parser'

describe JSONAPI::Request do


  body_hash = { 
    data: {
      type: "articles",
      id: "1",
      attributes: {
        title: "JSON:API paints my bikeshed!"
      },
      links: {
        self: "http://example.com/articles/1"
      },
      relationships: {
        author: {
          links: {
            self: "http://example.com/articles/1/relationships/author",
            related: "http://example.com/articles/1/author"
          },
          data: { type: "people", id: "9" }
        },
        comments: {
          links: {
            self: "http://example.com/articles/1/relationships/comments",
            related: "http://example.com/articles/1/comments"
          },
          data: [
            { type: "comments", id: "5" },
            { type: "comments", id: "12" }
          ]
        }
      }
    },
    included: [{
      type: "people",
      id: "9",
      attributes: {
        "first-name": "Dan",
        "last-name": "Gebhardt",
        twitter: "dgeb"
      },
      links: {
        self: "http://example.com/people/9"
      }
    }, {
      type: "comments",
      id: "5",
      attributes: {
        body: "First!"
      },
      relationships: {
        author: {
          data: { type: "people", id: "2" }
        }
      },
      links: {
        self: "http://example.com/comments/5"
      }
    }, {
      type: "comments",
      id: "12",
      attributes: {
        body: "I like XML better"
      },
      relationships: {
        author: {
          data: { type: "people", id: "9" }
        }
      },
      links: {
        self: "http://example.com/comments/12"
      }
    }]
  }

  body_str = Oj.dump(body_hash)

  let(:env) do
    {
      'SERVER_SOFTWARE' => 'thin 1.7.2 codename Bachmanity',
      'SERVER_NAME' => 'localhost',
      "rack.input" => StringIO.new(body_str),
      'rack.version' => [1, 0],
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => false,
      'REQUEST_METHOD' => 'POST',
      'REQUEST_PATH' => '/articles',
      'PATH_INFO' => '/articles',
      'QUERY_STRING' => 'include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh_ua=demoss&page[offset]=1&page[limit]=1',
      'REQUEST_URI' => '/articles?include=author,comments&fields[articles]=title,body,author&fields[people]=name&=demoss&page[offset]=1&page[limit]=1',
      'HTTP_VERSION' => 'HTTP/1.1', 
      'HTTP_ACCEPT' => 'application/vnd.beta.curatess.v1.api+json ; q=0.5, text/*, image/* ; q=.3',
      'HTTP_POSTMAN_TOKEN' => 'de878a8f-917e-4016-b9f7-f723a6483f03',
      'HTTP_HOST' => 'localhost:9292',
      'CONTENT_TYPE' => 'application/vnd.api+json',
      'GATEWAY_INTERFACE' => 'CGI/1.2',
      'SERVER_PORT' => '9292',
      'SERVER_PROTOCOL' => 'HTTP/1.1',
      'rack.url_scheme' => 'http',
      'SCRIPT_NAME' => '',
      'REMOTE_ADDR' => '::1'
    }
  end

  let(:req) { JSONAPI::Parser.parse_request(env) }

  let(:rack_req) { Rack::Request.new(env) }

  context 'when checking accessor methods' do
    it 'should be able to read path, protocol, host, port, query_string' do
      expect(req.path).to eq rack_req.path
      expect(req.http_method).to eq rack_req.request_method
      expect(req.host).to eq rack_req.host
      expect(req.port).to eq rack_req.port
      expect(req.query_string).to eq rack_req.query_string
    end

    it 'should also be able to access params, headers, and body' do
      expect(req.params.class).to eq JSONAPI::Request::QueryParamCollection
      expect(req.headers.class).to eq JSONAPI::HeaderCollection
      expect(req.body.class).to eq JSONAPI::Document
    end

    it 'should raise if attempting to overwrite an instance variable' do
      expect { req.path = 'new_path' }.to raise_error NoMethodError
      expect { req.method = 'new_method' }.to raise_error NoMethodError
      expect { req.host = 'new_host' }.to raise_error NoMethodError
      expect { req.port = 'new_port' }.to raise_error NoMethodError
      expect { req.query_string = 'new_query_string' }.to raise_error NoMethodError
      expect { req.params = 'new_params' }.to raise_error NoMethodError
      expect { req.headers = 'new_headers' }.to raise_error NoMethodError
      expect { req.body = 'new_body' }.to raise_error NoMethodError
    end
  end
end
