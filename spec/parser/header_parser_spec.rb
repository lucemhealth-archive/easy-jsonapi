# frozen_string_literal: true

require 'rack/jsonapi/parser'
require 'rack/jsonapi/parser/headers_parser'

require 'rack/jsonapi/item'
require 'rack/jsonapi/item/header'

require 'rack/jsonapi/collection'
require 'rack/jsonapi/collection/header_collection'

describe JSONAPI::Parser::HeadersParser do

  let(:env) do
    {
      'SERVER_SOFTWARE' => 'thin 1.7.2 codename Bachmanity',
      'SERVER_NAME' => 'localhost',
      'rack.version' => [1, 0],
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => false,
      'REQUEST_METHOD' => 'POST',
      'REQUEST_PATH' => '/articles',
      'PATH_INFO' => '/articles',
      'QUERY_STRING' => 'include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh=demoss&page[offset]=1&page[limit]=1',
      'REQUEST_URI' => '/articles?include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh=demoss&page[offset]=1&page[limit]=1',
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

  let(:hc) { JSONAPI::Parser::HeadersParser.parse!(env) }
  
  describe '#parse!' do
    
    it 'should return a header collection' do
      expect(hc.class).to eq JSONAPI::Collection::HeaderCollection
    end

    it 'should have the right header names and values' do
      expect(hc.size).to eq 4
      expect(hc.include?(:host)).to be true
      expect(hc.include?(:accept)).to be true
      expect(hc.include?(:content_type)).to be true
      expect(hc.include?(:postman_token)).to be true
    end
  end
end
