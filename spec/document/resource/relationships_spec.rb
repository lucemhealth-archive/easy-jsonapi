# frozen_string_literal: true

require 'rack/jsonapi/document/resource/relationships/relationship'
require 'shared_examples/collection_like_classes_tests'
require 'rack/jsonapi/parser/document_parser'

describe JSONAPI::Document::Resource::Relationships do
  it_behaves_like 'collection-like classes' do
    let(:item_class) { JSONAPI::Document::Resource::Relationships::Relationship }
    
    let(:relationships_hash) do 
      {
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
    end

    let(:ex_relstionship) do
      {
        "links": {
          "self": "http://example.com/articles/1/relationships/author",
          "related": "http://example.com/articles/1/author"
        },
        "data": { "type": "people", "id": "9" }
      }
    end

    let(:c_size) { 2 }
    let(:keys) { %i[author comments] }
    let(:ex_item_key) { :author }
    
    # Name is test so that it works with collection_like_classes_test.rb
    let(:ex_item) { JSONAPI::Parser::DocumentParser.parse_relationship!(:author, ex_relstionship) }
    
    let(:to_string) do
      '{ ' \
        "\"author\": { " \
          "\"links\": { " \
            "\"self\": \"http://example.com/articles/1/relationships/author\", " \
            "\"related\": \"http://example.com/articles/1/author\"" \
          ' }, ' \
          "\"data\": { \"type\": \"people\", \"id\": \"9\" }" \
        ' }, ' \
        "\"comments\": { " \
          "\"links\": { " \
            "\"self\": \"http://example.com/articles/1/relationships/comments\", " \
            "\"related\": \"http://example.com/articles/1/comments\"" \
          ' }, ' \
          "\"data\": [" \
            "{ \"type\": \"comments\", \"id\": \"5\" }, " \
            "{ \"type\": \"comments\", \"id\": \"12\" }" \
          ']' \
        ' }' \
      ' }'
    end

    let(:c) { JSONAPI::Parser::DocumentParser.parse_relationships!(relationships_hash) }
    let(:ec) { JSONAPI::Document::Resource::Relationships.new }
    
  end
end
