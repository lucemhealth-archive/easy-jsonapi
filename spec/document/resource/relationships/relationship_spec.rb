# frozen_string_literal: true

require 'rack/jsonapi/document/resource/relationships/relationship'
require 'rack/jsonapi/parser/document_parser'

describe JSONAPI::Document::Resource::Relationships::Relationship do
  
  rel_hash = {
    "links": {
      "self": "http://example.com/articles/1/relationships/author",
      "related": "http://example.com/articles/1/author"
    },
    "data": { "type": "people", "id": "9" },
    "meta": { "count": "1" }
  }

  let(:rel) do 
    JSONAPI::Parser::DocumentParser.parse_relationship!(:author, rel_hash)
  end
  
  context 'checking accessor methods' do
    it 'should be able to access members and get proper classes' do
      expect(rel.links.class).to eq JSONAPI::Document::Links
      expect(rel.data.class).to eq JSONAPI::Document::ResourceId
      expect(rel.meta.class).to eq JSONAPI::Document::Meta
    end
  
    it 'should have proper read methods' do
      expect(rel.name).to eq 'author'
      expect(rel.links.first.name).to eq 'self'
      expect(rel.data.type).to eq 'people'
      expect(rel.meta.get(:count).name).to eq 'count'
    end
  
    it 'should have proper write methods and raise when envoking on read only' do
      expect(rel.links.first.name = 'new_self').to eq 'new_self'
      expect(rel.data.type = 'new_type').to eq 'new_type'
      expect(rel.meta.get(:count).name = 'new_name').to eq 'new_name'
      expect { rel.name = 'new_name' }.to raise_error NoMethodError
    end
  end

  describe '#to_s' do
    to_string = 
      "\"author\": { " \
        "\"links\": { " \
          "\"self\": \"http://example.com/articles/1/relationships/author\", " \
          "\"related\": \"http://example.com/articles/1/author\" " \
        '}, ' \
        "\"data\": { \"type\": \"people\", \"id\": \"9\" }, " \
        "\"meta\": { \"count\": \"1\" } " \
      '}'

    it 'should work' do
      expect(rel.to_s).to eq to_string
    end
  end
end
