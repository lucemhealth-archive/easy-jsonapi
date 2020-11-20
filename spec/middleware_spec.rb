# frozen_string_literal: true

require 'rack/jsonapi/middleware'
require 'rack_app'
require 'oj'

describe JSONAPI::Middleware do

  app = RackApp.new
  let(:m) { JSONAPI::Middleware.new(app) }

  body_hash = { 
    "data": {
      "type": "articles",
      "id": "1",
      "attributes": {
        "title": "JSON:API paints my bikeshed!"
      },
      "links": {
        "self": "http://example.com/articles/1"
      },
      "relationships": {
        "author": {
          "links": {
            "self": "http://example.com/articles/1/relationships/author",
            "related": "http://example.com/articles/1/author"
          },
          "data": { "type": "people", "id": "9" }
        },
        "comments": {
          "links": {
            "self": "http://example.com/articles/1/relationships/comments",
            "related": "http://example.com/articles/1/comments"
          },
          "data": [
            { "type": "comments", "id": "5" },
            { "type": "comments", "id": "12" }
          ]
        }
      }
    },
    "included": [{
      "type": "people",
      "id": "9",
      "attributes": {
        "first-name": "Dan",
        "last-name": "Gebhardt",
        "twitter": "dgeb"
      },
      "links": {
        "self": "http://example.com/people/9"
      }
    }, {
      "type": "comments",
      "id": "5",
      "attributes": {
        "body": "First!"
      },
      "relationships": {
        "author": {
          "data": { "type": "people", "id": "2" }
        }
      },
      "links": {
        "self": "http://example.com/comments/5"
      }
    }, {
      "type": "comments",
      "id": "12",
      "attributes": {
        "body": "I like XML better"
      },
      "relationships": {
        "author": {
          "data": { "type": "people", "id": "9" }
        }
      },
      "links": {
        "self": "http://example.com/comments/12"
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

  bad_body_hash = { 
    "data": {
      "id": "1",
      "attributes": {
        "title": "JSON:API paints my bikeshed!"
      },
      "links": {
        "self": "http://example.com/articles/1"
      },
      "relationships": {
        "author": {
          "links": {
            "self": "http://example.com/articles/1/relationships/author",
            "related": "http://example.com/articles/1/author"
          },
          "data": { "type": "people", "id": "9" }
        },
        "comments": {
          "links": {
            "self": "http://example.com/articles/1/relationships/comments",
            "related": "http://example.com/articles/1/comments"
          },
          "data": [
            { "type": "comments", "id": "5" },
            { "type": "comments", "id": "12" }
          ]
        }
      }
    }
  }

  bad_body_str = Oj.dump(bad_body_hash)

  let(:env_bad_doc) do
    {
      'SERVER_SOFTWARE' => 'thin 1.7.2 codename Bachmanity',
      'SERVER_NAME' => 'localhost',
      "rack.input" => StringIO.new(bad_body_str),
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

  let(:env_bad_param) do
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
      'QUERY_STRING' => 'include=author,comments&fields[articles]=title,body,author&fields[people]=name&joshua=demoss&page[offset]=1&page[limit]=1',
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

  let(:doc_error) { JSONAPI::Exceptions::DocumentExceptions::InvalidDocument }
  let(:headers_error) { JSONAPI::Exceptions::HeadersExceptions::InvalidHeader }
  let(:query_params_error) { JSONAPI::Exceptions::QueryParamsExceptions::InvalidQueryParameter }

  let(:response) { [200, { "Content-Type" => "text/plain" }, ['Testing: JSONAPI::Request']] }

  describe '#call' do
    it 'should return the right response and instantiate a request object' do
      resp = m.call(env)
      expect(resp).to eq response
    end

    context 'when part of the document does not follow the spec' do
      it 'should raise InvalidDocument' do
        expect { m.call(env_bad_doc) }.to raise_error doc_error
      end
    end

    context 'when a query param is invalid and it is a jsonapi request' do
      it 'should raise InvalidQueryParameter' do
        expect { m.call(env_bad_param) }.to raise_error query_params_error
      end
    end
  end
end
