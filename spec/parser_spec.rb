# frozen_string_literal: true

require 'rack/jsonapi/parser'
require 'rack/jsonapi/request'

require 'oj'

describe JSONAPI::Parser do
  
  describe '#parse_request!' do

    # Alias method
    # @param (see JSONAPI::Parser#parse_request!)
    def parse_request!(env, document_included)
      JSONAPI::Parser.parse_request!(env, document_included)
    end

    it 'should return a Request object' do
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

      env = {
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
      
      expect(parse_request!(env, true).class).to eq JSONAPI::Request
    end

    # it 'should initialize request with an empty document if !document_included' do
      
    # end
  end
end
