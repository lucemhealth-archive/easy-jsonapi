# frozen_string_literal: true

require 'easy/jsonapi/document'

require 'easy/jsonapi/parser'
require 'easy/jsonapi/parser/json_parser'
require 'easy/jsonapi/parser/document_parser'

require 'easy/jsonapi/exceptions/document_exceptions'


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

  body = JSONAPI::Parser::JSONParser.dump(doc_hash)

  let(:document) { JSONAPI::Parser::DocumentParser.parse(body) }

  describe '#parse' do
    it 'should return nil if given a nil document' do
      expect(JSONAPI::Parser::DocumentParser.parse(nil)).to be nil
    end
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
