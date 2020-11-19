# frozen_string_literal: true

require 'rack/jsonapi/exceptions/headers_exceptions'

describe JSONAPI::Exceptions::HeadersExceptions do

  # Should pass
  let(:env1) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'text/plain'
    }
  end

  # Should pass
  let(:env2) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # Should pass
  let(:env3) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end
  
  # Should raise error bc of content type
  let(:env4) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'application/vnd.api+json; idk'
    }
  end

  # Should raise error because of HTTP_ACCEPT
  let(:env5) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json ; q=0.5, text/*, image/* ; q=.3',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # Should raise error because of both
  let(:env6) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json ; q=0.5, text/*, image/* ; q=.3',
      'CONTENT_TYPE' => 'application/vnd.api+json ; idk'
    }
  end

  let(:error_class) { JSONAPI::Exceptions::HeadersExceptions::InvalidHeader }

  describe '#compliant?' do
    it 'should pass if both CONTENT_TYPE and ACCEPT headers comply' do
      expect(JSONAPI::Exceptions::HeadersExceptions.check_compliance(env1)).to be nil
      expect(JSONAPI::Exceptions::HeadersExceptions.check_compliance(env2)).to be nil
      expect(JSONAPI::Exceptions::HeadersExceptions.check_compliance(env3)).to be nil
    end

    it 'should raise InvalidHeader if either CONTENT_TYPE or ACCEPT headers do not comply' do
      expect { JSONAPI::Exceptions::HeadersExceptions.check_compliance(env4) }.to raise_error error_class
      expect { JSONAPI::Exceptions::HeadersExceptions.check_compliance(env5) }.to raise_error error_class
      expect { JSONAPI::Exceptions::HeadersExceptions.check_compliance(env6) }.to raise_error error_class
    end
  end
end
