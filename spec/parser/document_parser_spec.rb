# frozen_string_literal: true

require 'rack/jsonapi/document'
require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/document/resource_id'

require 'rack/jsonapi/document/resource/attributes'
require 'rack/jsonapi/document/resource/attributes/attribute'

require 'rack/jsonapi/document/resource/relationships'

require 'rack/jsonapi/document/links'
require 'rack/jsonapi/document/links/link'

require 'rack/jsonapi/document/meta'
require 'rack/jsonapi/document/meta/meta_member'

require 'rack/jsonapi/document/included'

require 'rack/jsonapi/parser'
require 'rack/jsonapi/parser/document_parser'

require 'rack/jsonapi/exceptions/document_exceptions'

require 'oj'

describe JSONAPI::Parser::DocumentParser do 

  doc_hash =
    {
      'data' => {
        'type' => 'articles',
        'id' => '1',
        'attributes' => { 'title' => 'JSON API paints my bikeshed!' },
        'links' => { 'self' => 'http://example.com/articles/1' },
        'relationships' => {
          'author' => {
            'links' => {
              'self' => 'http://example.com/articles/1/relationships/author',
              'related' => 'http://example.com/articles/1/author'
            },
            'data' => { 'type' => 'people', 'id' => '9' }
          },
          'journal' => {
            'data' => nil
          },
          'comments' => {
            'links' => {
              'self' => 'http://example.com/articles/1/relationships/comments',
              'related' => 'http://example.com/articles/1/comments'
            },
            'data' => [
              { 'type' => 'comments', 'id' => '5' },
              { 'type' => 'comments', 'id' => '12' }
            ]
          }
        }
      },
      'meta' => { 'count' => '13' },
      'links' => { 'self' => 'url' }
    }

  oj_formatted_hash = Oj.load(Oj.dump(doc_hash), symbol_keys: true)

  let(:document) { JSONAPI::Parser::DocumentParser.parse!(oj_formatted_hash, is_a_request: true) }

  describe '#parse!' do
    it 'should return a Document object given a valid jsonapi document' do
      expect(document.class).to eq JSONAPI::Document
    end

    it 'the document classes instance variables should associate w the proper class' do
      expect(document.data.class).to eq JSONAPI::Document::Resource
      expect(document.meta.class).to eq JSONAPI::Document::Meta
      expect(document.links.class).to eq JSONAPI::Document::Links
    end

  end
  
  
end
