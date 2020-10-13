# # frozen_string_literal: true

# require 'rack/jsonapi/document'

# require 'rack/jsonapi/parser'
# require 'rack/jsonapi/parser/document_parser'

# describe JSONAPI::Parser::DocumentParser do 

#   let(:doc) do
#     {
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
#   end

#   describe '#parse!' do
#     it 'should not raise an error given a valid jsonapi document' do
#       expect { JSONAPI::Parser::DocumentParser.parse!(doc) }.not_to raise_error
#     end
#   end
  
#   # it 'succeeds on nil data' do
#   #   payload = { 'data' => nil }

#   #   expect { JSONAPI::Parser::ParseDocument.parse!(payload) }.not_to raise_error
#   # end

#   # it 'succeeds on empty array data' do
#   #   payload = { 'data' => [] }

#   #   expect { JSONAPI::Parser::ParseDocument.parse!(payload) }.not_to raise_error
#   # end

#   # it 'works' do
    

#   #   expect { JSONAPI::Parser::ParseDocument.parse!(payload) }.not_to raise_error
#   # end

#   # it 'passes regardless of id/type order' do
#   #   payload = {
#   #     'data' => [
#   #       {
#   #         'type' => 'articles',
#   #         'id' => '1',
#   #         'relationships' => {
#   #           'comments' => {
#   #             'data' => [
#   #               { 'type' => 'comments', 'id' => '5' },
#   #               { 'id' => '12', 'type' => 'comments' }
#   #             ]
#   #           }
#   #         }
#   #       }
#   #     ]
#   #   }

#   #   expect { JSONAPI::Parser::ParseDocument.parse!(payload) }.to_not raise_error
#   # end

#   # it 'fails when an element is missing type or id' do
#   #   payload = {
#   #     'data' => [
#   #       {
#   #         'type' => 'articles',
#   #         'id' => '1',
#   #         'relationships' => {
#   #           'author' => {
#   #             'data' => { 'type' => 'people' }
#   #           }
#   #         }
#   #       }
#   #     ]
#   #   }

#   #   expect { JSONAPI::Parser::ParseDocument.parse!(payload) }.to raise_error(
#   #     JSONAPI::Parser::InvalidDocument,
#   #     'A resource identifier object MUST contain ["id", "type"] members.'
#   #   )
#   # end
# end
