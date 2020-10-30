# frozen_string_literal: true

require 'rack/jsonapi/document'
require 'rack/jsonapi/parser/document_parser'

describe JSONAPI::Document do

  doc_hash = {
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
      }
    },
    meta: { count: '13' },
    links: { self: 'url' }
  }

  doc = JSONAPI::Parser::DocumentParser.parse!(doc_hash)

  let(:d) { doc }

  let(:ec) { JSONAPI::Exceptions::DocumentExceptions::InvalidDocument }
  
  describe '#initialize' do
    it 'should not raise an error if passed nil as an argument' do
      msg = "A document MUST contain at least one of the following top-level members: [:data, :errors, :meta]"
      expect { JSONAPI::Document.new({}) }.to raise_error(ec, msg)
    end

    it 'should provide nil for instance variables that are not present' do
      expect(d.errors).to eq nil
      expect(d.jsonapi).to eq nil
      expect(d.included).to eq nil
    end

    it 'should have the appropriate classes associated with each instance variable' do
      # expect()
    end
  end

  
end
