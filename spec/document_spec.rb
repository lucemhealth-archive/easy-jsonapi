# frozen_string_literal: true

require 'json'

require 'rack/jsonapi/document'
require 'rack/jsonapi/parser/document_parser'

require 'rack/jsonapi/exceptions/document_exceptions'

require 'rack/jsonapi/document/resource'

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

  let(:doc_hash) { doc_hash }

  doc = JSONAPI::Parser::DocumentParser.parse!(doc_hash)

  let(:d) { doc }

  let(:ec) { JSONAPI::Exceptions::DocumentExceptions::InvalidDocument }

  describe '#initialize' do
    it 'should not raise Invalid Document if passed an invalid document.' do
      msg = 'A document MUST be initialized with a hash containing ' \
            "at least one of the following keys: [:data, :errors, :meta, " \
            ":jsonapi, :links, :included]"
      expect { JSONAPI::Document.new(nil) }.to raise_error msg
      expect { JSONAPI::Document.new({}) }.to raise_error(ec, msg)
      msg = 'Unless otherwise noted, objects defined by this specification ' \
            'MUST NOT contain any additional members - ADDITIONAL MEMBERS FOUND: [:extra]'
      expect { JSONAPI::Document.new({ data: nil, extra: nil }) }.to raise_error msg
    end

    it 'should provide nil for instance variables that are not present' do
      expect(d.errors).to eq nil
      expect(d.jsonapi).to eq nil
      expect(d.included).to eq nil
    end

    it 'should have the appropriate classes associated with each instance variable' do
      expect(d.data.class).to eq JSONAPI::Document::Resource
      expect(d.meta.class).to eq JSONAPI::Document::Meta
      expect(d.links.class).to eq JSONAPI::Document::Links

      # a = JSON.parse(d.to_s)
      # a.to_json
    end
  end

  describe '#to_s' do
    it 'should output a string that can be parsed by a JSON parser' do
      expect(JSON.parse(doc.to_s, symbolize_names: true)).to eq doc_hash
    end
  end



  
end
