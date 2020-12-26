# frozen_string_literal: true

require 'rack/jsonapi/parser'
require 'rack/jsonapi/request'

require 'oj'

describe JSONAPI::Parser do
  
  describe '#parse_request!' do

    req_body_hash = {
      "data": {
        "type": "photos",
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "attributes": {
          "title": "Ember Hamster",
          "src": "http://example.com/images/productivity.png"
        }
      }
    }

    req_body_str = Oj.dump(req_body_hash)

    env = 
      {
        'SERVER_SOFTWARE' => 'thin 1.7.2 codename Bachmanity',
        'SERVER_NAME' => 'localhost',
        "rack.input" => StringIO.new(req_body_str),
        'rack.version' => [1, 0],
        'rack.multithread' => false,
        'rack.multiprocess' => false,
        'rack.run_once' => false,
        'REQUEST_METHOD' => 'POST',
        'REQUEST_PATH' => '/articles',
        'PATH_INFO' => '/articles',
        'QUERY_STRING' => 'include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh_ua=demoss&page[offset]=1&page[limit]=1',
        'REQUEST_URI' => '/articles?include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh_ua=demoss&page[offset]=1&page[limit]=1',
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

    env_get_w_body =
      {
        "SERVER_SOFTWARE" => "thin 1.8.0 codename Possessed Pickle",
        "SERVER_NAME" => "localhost",
        "rack.input" => StringIO.new(req_body_str),
        "rack.version" => [1, 0],
        "rack.multithread" => true,
        "rack.multiprocess" => false,
        "rack.run_once" => false,
        "REQUEST_METHOD" => "GET",
        "REQUEST_PATH" => "/person/5632139873746944",
        "PATH_INFO" => "/person/5632139873746944",
        "REQUEST_URI" => "/person/5632139873746944",
        "HTTP_VERSION" => "HTTP/1.1",
        "HTTP_USER_AGENT" => "PostmanRuntime/7.26.8",
        "HTTP_ACCEPT" => "*/*",
        "HTTP_POSTMAN_TOKEN" => "ad8b44f0-8f24-43a3-a6d8-f4291929e00b",
        "HTTP_HOST" => "localhost:4567",
        "HTTP_ACCEPT_ENCODING" => "gzip, deflate, br",
        "HTTP_CONNECTION" => "keep-alive",
        "CONTENT_LENGTH" => "89",
        "CONTENT_TYPE" => "application/vnd.api+json",
        "GATEWAY_INTERFACE" => "CGI/1.2",
        "SERVER_PORT" => "4567",
        "QUERY_STRING" => "",
        "SERVER_PROTOCOL" => "HTTP/1.1",
        "rack.url_scheme" => "http",
        "SCRIPT_NAME" => "",
        "REMOTE_ADDR" => "::1",
        "sinatra.commonlogger" => true,
        "rack.request.query_string" => "",
        "rack.request.query_hash" => {},
        "sinatra.route" => "GET /:type/:id/?"
      }

    env_no_body = 
      {
        'SERVER_SOFTWARE' => 'thin 1.7.2 codename Bachmanity',
        'SERVER_NAME' => 'localhost',
        "rack.input" => StringIO.new,
        'rack.version' => [1, 0],
        'rack.multithread' => false,
        'rack.multiprocess' => false,
        'rack.run_once' => false,
        'REQUEST_METHOD' => 'POST',
        'REQUEST_PATH' => '/articles',
        'PATH_INFO' => '/articles',
        'QUERY_STRING' => 'include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh_ua=demoss&page[offset]=1&page[limit]=1',
        'REQUEST_URI' => '/articles?include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh_ua=demoss&page[offset]=1&page[limit]=1',
        'HTTP_VERSION' => 'HTTP/1.1', 
        'HTTP_ACCEPT' => 'application/vnd.beta.curatess.v1.api+json ; q=0.5, text/*, image/* ; q=.3',
        'HTTP_POSTMAN_TOKEN' => 'de878a8f-917e-4016-b9f7-f723a6483f03',
        'HTTP_HOST' => 'localhost:9292',
        'GATEWAY_INTERFACE' => 'CGI/1.2',
        'SERVER_PORT' => '9292',
        'SERVER_PROTOCOL' => 'HTTP/1.1',
        'rack.url_scheme' => 'http',
        'SCRIPT_NAME' => '',
        'REMOTE_ADDR' => '::1'
      }
      
    req = JSONAPI::Parser.parse_request(env)
    req_get_w_body = JSONAPI::Parser.parse_request(env_get_w_body)
    req_no_body = JSONAPI::Parser.parse_request(env_no_body)

    let(:req) { req }
    let(:req_get_w_body) { req_get_w_body }

    let(:req_no_body) { req_no_body }


      
    it 'should return a Request object' do
      expect(req.class).to eq JSONAPI::Request
      expect(req_get_w_body.class).to eq JSONAPI::Request
      expect(req_no_body.class).to eq JSONAPI::Request
    end
    
    context 'when a jsonapi document is not included with the request' do
      it 'should return nil when accessing the request body' do
        expect(req_get_w_body.body).to eq nil
        expect(req_no_body.body).to eq nil
      end        
    end
  end
end
