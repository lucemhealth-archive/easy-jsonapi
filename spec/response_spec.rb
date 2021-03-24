# frozen_string_literal: true

require 'easy/jsonapi/response'
require 'shared_contexts/document_exceptions_shared_context'
require 'shared_contexts/headers_exceptions_shared_context'

describe JSONAPI::Response do
  include_context 'document exceptions'
  include_context 'headers exceptions'

  describe '#validate' do
    it 'should return nil if given a valid body and headers' do
      expect(JSONAPI::Response.validate(response_doc, env1)).to be nil
    end

    it 'should raise InvalidHeader if a header is found to be non compliant' do
      expect { JSONAPI::Response.validate(response_doc, env4) }.to raise_error hec
    end
    
    it 'should raise InvalidDocument if the document is found to be non compliant' do
      expect { JSONAPI::Response.validate({}, env1) }.to raise_error dec
    end
  end
end
