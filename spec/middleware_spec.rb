# # frozen_string_literal: true

# require 'rack/jsonapi/middleware'
# require './spec/rack_app'

# describe JSONAPI::Middleware do

#   let(:app) { RackApp.new }

#   let(:m) { JSONAPI::Middleware.new(app) }

#   let(:env) do
#     {
#       'SERVER_SOFTWARE' => 'thin 1.7.2 codename Bachmanity',
#       'SERVER_NAME' => 'localhost',
#       "rack.input" => StringIO.new 
#       'rack.version' => [1, 0],
#       'rack.multithread' => false,
#       'rack.multiprocess' => false,
#       'rack.run_once' => false,
#       'REQUEST_METHOD' => 'POST',
#       'REQUEST_PATH' => '/articles',
#       'PATH_INFO' => '/articles',
#       'QUERY_STRING' => 'include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh=demoss&page[offset]=1&page[limit]=1',
#       'REQUEST_URI' => '/articles?include=author,comments&fields[articles]=title,body,author&fields[people]=name&josh=demoss&page[offset]=1&page[limit]=1',
#       'HTTP_VERSION' => 'HTTP/1.1', 
#       'HTTP_ACCEPT' => 'application/vnd.beta.curatess.v1.api+json ; q=0.5, text/*, image/* ; q=.3',
#       'HTTP_POSTMAN_TOKEN' => 'de878a8f-917e-4016-b9f7-f723a6483f03',
#       'HTTP_HOST' => 'localhost:9292',
#       'CONTENT_TYPE' => 'application/vnd.api+json',
#       'GATEWAY_INTERFACE' => 'CGI/1.2',
#       'SERVER_PORT' => '9292',
#       'SERVER_PROTOCOL' => 'HTTP/1.1',
#       'rack.url_scheme' => 'http',
#       'SCRIPT_NAME' => '',
#       'REMOTE_ADDR' => '::1'
#     }

#   end

#   describe '#call' do
#     it 'should trigger the middleware if the Content-Type is application/vnd.api+json' do
#       expect(app.instance_variables).to eq []
#       m.call(env)
#       expect(app.instance_variables).to eq [@jsonapi_request]
#     end
#   end
# end
