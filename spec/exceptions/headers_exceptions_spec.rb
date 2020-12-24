# frozen_string_literal: true

require 'rack/jsonapi/exceptions/headers_exceptions'
require 'shared_contexts/headers_exceptions_shared_context'

describe JSONAPI::Exceptions::HeadersExceptions do

  include_context 'headers exceptions'
  # envs are located ^
  # hec located ^ as well
  

  describe '#compliant?' do
    it 'should pass if both CONTENT_TYPE and ACCEPT headers comply' do
      expect(JSONAPI::Exceptions::HeadersExceptions.check_compliance(env1)).to be nil
      expect(JSONAPI::Exceptions::HeadersExceptions.check_compliance(env2)).to be nil
      expect(JSONAPI::Exceptions::HeadersExceptions.check_compliance(env3)).to be nil
    end

    it 'should raise InvalidHeader if either CONTENT_TYPE or ACCEPT headers do not comply' do
      expect { JSONAPI::Exceptions::HeadersExceptions.check_compliance(env4) }.to raise_error hec
      expect { JSONAPI::Exceptions::HeadersExceptions.check_compliance(env5) }.to raise_error hec
      expect { JSONAPI::Exceptions::HeadersExceptions.check_compliance(env6) }.to raise_error hec
    end
  end
end
