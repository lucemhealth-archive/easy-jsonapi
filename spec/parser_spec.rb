# require 'spec_helper'

# RSpec.describe Application do
#   context "get to /ruby/monstas" do
#     let(:app)      { lambda {|env| [200, {'Content-Type' => 'text/plain'}, ['OK']]} }
#     let(:env)      { { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/ruby/monstas" } }
#     let(:response) { app.call(env) }
#     let(:body)     { response[2][0] }

#     it "returns the body" do
#       expect(body).to eq "You have requested the path /ruby/monstas, using GET"
#     end
#   end
# end

# describe JSONAPI::Parser do

#   describe '.parse_request!' do
#       context 'Testing '
#   end

#   describe ParseParams do

#   end

#   describe ParseHeaders do

#   end

#   describe ParseDocument do

#   end

#     it 'succeeds on nil data' do
#         payload = { 'data' => nil }

#         expect { JSONAPI.parse_response!(payload) }.not_to raise_error
#     end

#   it 'succeeds on empty array data' do
#     payload = { 'data' => [] }

#     expect { JSONAPI.parse_response!(payload) }.not_to raise_error
#   end

#   it 'works' do
#     payload = {
#       'data' => [
#         {
#           'type' => 'articles',
#           'id' => '1',
#           'attributes' => { 'title' => 'JSON API paints my bikeshed!' },
#           'links' => { 'self' => 'http://example.com/articles/1' },
#           'relationships' => {
#             'author' => {
#               'links' => {
#                 'self' => 'http://example.com/articles/1/relationships/author',
#                 'related' => 'http://example.com/articles/1/author'
#               },
#               'data' => { 'type' => 'people', 'id' => '9' }
#             },
#             'journal' => {
#               'data' => nil
#             },
#             'comments' => {
#               'links' => {
#                 'self' => 'http://example.com/articles/1/relationships/comments',
#                 'related' => 'http://example.com/articles/1/comments'
#               },
#               'data' => [
#                 { 'type' => 'comments', 'id' => '5' },
#                 { 'type' => 'comments', 'id' => '12' }
#               ]
#             }
#           }
#         }
#       ],
#       'meta' => { 'count' => '13' }
#     }

#     expect { JSONAPI.parse_response!(payload) }.not_to raise_error
#   end

#   it 'passes regardless of id/type order' do
#     payload = {
#       'data' => [
#         {
#           'type' => 'articles',
#           'id' => '1',
#           'relationships' => {
#             'comments' => {
#               'data' => [
#                 { 'type' => 'comments', 'id' => '5' },
#                 { 'id' => '12', 'type' => 'comments' }
#               ]
#             }
#           }
#         }
#       ]
#     }

#     expect { JSONAPI.parse_response!(payload) }.to_not raise_error
#   end

#   it 'fails when an element is missing type or id' do
#     payload = {
#       'data' => [
#         {
#           'type' => 'articles',
#           'id' => '1',
#           'relationships' => {
#             'author' => {
#               'data' => { 'type' => 'people' }
#             }
#           }
#         }
#       ]
#     }

#     expect { JSONAPI.parse_response!(payload) }.to raise_error(
#       JSONAPI::Parser::InvalidDocument,
#       'A resource identifier object MUST contain ["id", "type"] members.'
#     )
#   end
# end
