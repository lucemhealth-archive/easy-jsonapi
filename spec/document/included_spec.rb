# frozen_string_literal: true

require 'rack/jsonapi/document/included'
require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/parser/document_parser'

describe JSONAPI::Document::Included do

  doc_hash = {
    "links": {
      "self": "http://example.com/articles",
      "next": "http://example.com/articles?page[offset]=2",
      "last": "http://example.com/articles?page[offset]=10"
    },
    "data": {
      "type": "articles",
      "id": "1",
      "attributes": {
        "title": "JSON:API paints my bikeshed!"
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
      },
      "links": {
        "self": "http://example.com/articles/1"
      }
    },
    "included": [
      {
        "type": "people",
        "id": "9",
        "attributes": {
          "firstName": "Dan",
          "lastName": "Gebhardt",
          "twitter": "dgeb"
        },
        "links": {
          "self": "http://example.com/people/9"
        }
      }, 
      {
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
      }, 
      {
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
      }
    ]
  }
  
  document = JSONAPI::Parser::DocumentParser.parse!(doc_hash)

  let(:i) { document.included }

  it 'should be enumerable' do
    expect(i.map(&:type)).to eq ['people', 'comments', 'comments']
    expect(i.first.type).to eq 'people'
  end

  it 'should return a proper to_s' do
    # puts i.to_s
  end

    
end
