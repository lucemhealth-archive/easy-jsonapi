# frozen_string_literal: true

require 'rack/jsonapi/response'
require 'shared_contexts/document_exceptions_shared_context'
require 'shared_contexts/headers_exceptions_shared_context'

describe JSONAPI::Response do
  include_context 'document exceptions'
  include_context 'headers exceptions'

  describe '#validate_body' do
    it 'should return nil given a valid response document' do
      expect(JSONAPI::Response.validate_body(response_doc)).to be nil
    end

    it 'should raise InvalidDocument when given an invalid response' do
      expect { JSONAPI::Response.validate_body({}) }.to raise_error dec
    end
  end

  describe '#validate_headers' do
    it 'should return nil given valid response headers' do
      expect(JSONAPI::Response.validate_headers(env1)).to be nil
      expect(JSONAPI::Response.validate_headers(env2)).to be nil
      expect(JSONAPI::Response.validate_headers(env3)).to be nil
    end

    it 'should raise InvalidHeader if given a invalid headers collection' do
      expect { JSONAPI::Response.validate_headers(env4) }.to raise_error hec
      expect { JSONAPI::Response.validate_headers(env5) }.to raise_error hec
      expect { JSONAPI::Response.validate_headers(env6) }.to raise_error hec
    end
  end
end
