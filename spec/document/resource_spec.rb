# frozen_string_literal: true

require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/parser/document_parser'

describe JSONAPI::Document::Resource do

  let(:res_hash) do
    {
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
          data: { type: 'people', id: '9' }
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
  end

  let(:res) { JSONAPI::Parser::DocumentParser.parse_resource(res_hash) }
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

    it 'should raise if initialized with something other than a hash' do
      msg = 'A JSONAPI::Document::Resource must be initialized with a Hash'
      expect { JSONAPI::Document::Resource.new(123) }.to raise_error msg
    end
  end

  describe '#to_s' do
    to_string = 
      '{ ' \
        "\"type\": \"articles\", " \
        "\"id\": \"1\", " \
        "\"attributes\": { \"title\": \"JSON API paints my bikeshed!\" }, " \
        "\"relationships\": { " \
          "\"author\": { " \
            "\"links\": { " \
              "\"self\": \"http://example.com/articles/1/relationships/author\", " \
              "\"related\": \"http://example.com/articles/1/author\" " \
            '}, ' \
            "\"data\": { \"type\": \"people\", \"id\": \"9\" } " \
          '}, ' \
          "\"comments\": { " \
            "\"links\": { " \
              "\"self\": \"http://example.com/articles/1/relationships/comments\", " \
              "\"related\": \"http://example.com/articles/1/comments\" " \
            '}, ' \
            "\"data\": [" \
              "{ \"type\": \"comments\", \"id\": \"5\" }, " \
              "{ \"type\": \"comments\", \"id\": \"12\" }" \
            '] ' \
          '} ' \
        '}, ' \
        "\"links\": { \"self\": \"http://example.com/articles/1\" }, " \
        "\"meta\": { \"count\": \"1\" } " \
      '}'

    it 'should be intuitive' do
      expect(res.to_s).to eq to_string
    end
  end

  describe '#to_h' do
    it 'should mimic JSON format' do
      expect(res.to_h).to eq res_hash
    end
  end
end
