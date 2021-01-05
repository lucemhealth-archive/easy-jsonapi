# frozen_string_literal: true

require 'rack/jsonapi/document'
require 'rack/jsonapi/parser/document_parser'
require 'rack/jsonapi/exceptions/document_exceptions'

require 'json'
require 'oj'

describe JSONAPI::Document do

  doc_hash = 
    {
      data: {
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
          # journal: {
          #   data: nil
          # },
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
        }
      },
      meta: { count: '13' },
      links: { self: 'url' }
    }

  doc_hash2 = {
    data: {
      type: 'person',
      attributes: {
        name: 'Caleb'
      }
    }
  }

  let(:body) { Oj.dump(doc_hash) }
  let(:body2) { Oj.dump(doc_hash2) }

  
  let(:d) { JSONAPI::Parser::DocumentParser.parse(body) }
  let(:d2) { JSONAPI::Parser::DocumentParser.parse(body2) }
  
  let(:dh) { JSONAPI::Parser::DocumentParser.parse_hash(Oj.load(body, symbol_keys: true)) }
  let(:dh2) { JSONAPI::Parser::DocumentParser.parse_hash(Oj.load(body2, symbol_keys: true)) }

  let(:ec) { JSONAPI::Exceptions::DocumentExceptions::InvalidDocument }

  describe '#initialize' do

    it 'should raise if not given a hash during initialization' do
      msg = 'JSONAPI::Document parameter must be a Hash'
      expect { JSONAPI::Document.new(1234) }.to raise_error msg
    end

    it 'should provide nil for instance variables that are not present' do
      expect(d.errors).to eq nil
      expect(d.jsonapi).to eq nil
      expect(d.included).to eq nil
      
      expect(dh.errors).to eq nil
      expect(dh.jsonapi).to eq nil
      expect(dh.included).to eq nil
    end

    it 'should have the appropriate classes associated with each instance variable' do
      expect(d.data.class).to eq JSONAPI::Document::Resource
      expect(d.meta.class).to eq JSONAPI::Document::Meta
      expect(d.links.class).to eq JSONAPI::Document::Links
      
      expect(dh.data.class).to eq JSONAPI::Document::Resource
      expect(dh.meta.class).to eq JSONAPI::Document::Meta
      expect(dh.links.class).to eq JSONAPI::Document::Links

      # a = JSON.parse(d.to_s)
      # a.to_json
    end
  end

  describe '#to_s' do
    it 'should output a string that can be parsed by a JSON parser' do
      expect(JSON.parse(d.to_s, symbolize_names: true)).to eq doc_hash
      expect(JSON.parse(dh.to_s, symbolize_names: true)).to eq doc_hash
    end
    
    it 'should not include id when id is not included in the original body' do
      d_hash = d2.to_h
      expect(d_hash[:data][:id].nil?).to be true
      
      dh_hash = dh2.to_h
      expect(dh_hash[:data][:id].nil?).to be true
    end
  end

  describe '#to_h' do
    it 'should mimic JSON format' do
      expect(d.to_h).to eq doc_hash
      expect(dh.to_h).to eq doc_hash
    end
  end

  describe '#validate' do
    it 'should return nil when given a valid document' do
      expect(d.validate).to be nil
      expect(dh.validate).to be nil
    end
  end
end
