# frozen_string_litral: true

require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/parser/document_parser'

describe JSONAPI::Document::Resource do

  res_hash = {
    type: 'articles',
    id: '1',
    attributes: { title: 'JSON API paints my bikeshed!' },
    links: { self: 'http://example.com/articles/1' },
    relationships: {
      author: {
        links: {
          self: 'http://example.com/articles/1/relationships/author',
          related: 'http://example.com/articles/1/author'
        },
        data: { type: 'people',  id: '9' }
      },
      journal: {
        data: nil
      },
      comments: {
        links: {
          self: 'http://example.com/articles/1/relationships/comments',
          related: 'http://example.com/articles/1/comments'
        },
        data: [
          { type: 'comments', id: '5' },
          { type: 'comments', id: '12' }
        ]
      }
    },
    meta: { count: '1' }
  }

  let(:res) { JSONAPI::Parser::DocumentParser.parse_resource!(res_hash) }
  let(:eres) { JSONAPI::Document::Resource.new }

  describe '#initialize' do
    it 'should have the right classes for each instance variable' do
      expect(res.type.class).to eq String
      expect(res.id.class).to eq String
      expect(res.attributes.class).to eq JSONAPI::Document::Resource::Attributes
      expect(res.relationships.class).to eq JSONAPI::Document::Resource::Relationships
      expect(res.links.class).to eq JSONAPI::Document::Links
      expect(res.meta.class).to eq JSONAPI::Document::Meta
    end
  end
end
