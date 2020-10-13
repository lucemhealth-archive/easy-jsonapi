# frozen_string_literal: true

require 'rack/jsonapi/exceptions'
require 'rack/jsonapi/exceptions/document_exceptions'
require 'rack/jsonapi/exceptions/param_exceptions'
require 'rack/jsonapi/exceptions/header_exceptions'

describe JSONAPI::Exceptions do

  let(:pe) { JSONAPI::Exceptions::ParamExceptions::InvalidParameter }
  let(:he) { JSONAPI::Exceptions::HeaderExceptions::InvalidHeader }
  let(:de) { JSONAPI::Exceptions::DocumentExceptions::InvalidDocument }

  describe '#raise_error' do
    it 'should raise the proper exceptions' do
      expect { JSONAPI::Exceptions.raise_error(pe, 'test message') }.to raise_error(pe, 'test message')
      expect { JSONAPI::Exceptions.raise_error(he, 'test message') }.to raise_error(he, 'test message')
      expect { JSONAPI::Exceptions.raise_error(de, 'test message') }.to raise_error(de, 'test message')
    end
  end
end
