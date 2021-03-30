# frozen_string_literal: true

require 'easy/jsonapi/exceptions/headers_exceptions'
require 'shared_contexts/headers_exceptions_shared_context'

describe JSONAPI::Exceptions::HeadersExceptions do

  include_context 'headers exceptions'
  # envs are located ^
  # hec located ^ as well

  def check_compliance(env)
    JSONAPI::Exceptions::HeadersExceptions.check_compliance(env)
  end

  def check_request(env, contains_body: false)
    JSONAPI::Exceptions::HeadersExceptions.check_request(env, nil, contains_body: contains_body)
  end

  describe '#check_response_compliance' do
    it 'should pass if both CONTENT_TYPE and ACCEPT headers comply' do
      expect(check_compliance(env1)).to be nil
    end

    it 'should raise InvalidHeader if either CONTENT_TYPE or ACCEPT headers do not comply' do
      expect { check_compliance(env2) }.to raise_error hec
      expect { check_compliance(env3) }.to raise_error hec
      expect { check_compliance(env4) }.to raise_error hec
      expect { check_compliance(env5) }.to raise_error hec
      expect { check_compliance(env6) }.to raise_error hec
      expect { check_compliance(env7) }.to raise_error hec
    end
  end

  describe '#check_request_compliance' do
    it 'should filter appropriately on GET requests' do
      expect { check_request(get_w_body, contains_body: true) }.to raise_error hec
      expect(check_request(get_no_hdrs)).to be nil
      expect { check_request(get_w_content_type1) }.to raise_error hec
      expect { check_request(get_w_content_type2) }.to raise_error hec
    end
    
    it 'should filter appropriately on POST,PATCH, or PUT requests' do
      expect { check_request(post_no_body, contains_body: true) }.to raise_error hec
      expect { check_request(post_no_content_type, contains_body: true) }.to raise_error hec
      expect { check_request(post_accept_not_jsonapi, contains_body: true) }.to raise_error hec
      expect { check_request(post_content_type_not_jsonapi, contains_body: true) }.to raise_error hec
      expect(check_request(post_content_type_and_accept_jsonapi, contains_body: true)).to be nil
      expect { check_request(post_content_type_jsonapi_but_accept_not_jsonapi, contains_body: true) }.to raise_error hec
    end
    
    it 'should filter appropriately on DELETE requests' do
      expect { check_request(delete_w_body, contains_body: true) }.to raise_error hec
      expect(check_request(delete_no_content_type_or_accept)).to be nil
      expect { check_request(delete_w_content_type) }.to raise_error hec
      expect(check_request(delete_accept_jsonapi)).to be nil
      expect { check_request(delete_not_accept_jsonapi) }.to raise_error hec
    end
  end
end
