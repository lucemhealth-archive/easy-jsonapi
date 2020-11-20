# frozen_string_literal: true

require 'rack/jsonapi/exceptions/query_params_exceptions'

describe JSONAPI::Exceptions::QueryParamsExceptions do
  
  # A hash that will fail
  let(:rp) do 
    {
      'include' => 'author,comments.author',
      'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
      'test' => 'ing',
      'page' => { 'offset' => '1', 'limit' => '1' }
    }
  end

  # A hash should pass
  let(:rpa) do 
    {
      'include' => 'author,comments.author',
      'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
      'testTest' => 'ing',
      'page' => { 'offset' => '1', 'limit' => '1' }
    }
  end
  
  # A hash that should pass
  let(:rpb) do 
    {
      'include' => 'author,comments.author',
      'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
      'test_test' => 'ing',
      'page' => { 'offset' => '1', 'limit' => '1' }
    }
  end
  
  # A hash that should pass
  let(:rpc) do 
    {
      'include' => 'author,comments.author',
      'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
      'test1' => 'ing',
      'page' => { 'offset' => '1', 'limit' => '1' }
    }
  end
  
  # A hash that should pass
  let(:no_impl_sp_p) do 
    {
      'include' => 'author,comments.author',
      'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
      'page' => { 'offset' => '1', 'limit' => '1' }
    }
  end
  
  # A hash that should pass
  let(:only_impl_sp_p) do 
    {
      'test1' => 'ing',
      'test2' => 'what?'
    }
  end

  # The error class to return
  let(:error_class) { JSONAPI::Exceptions::QueryParamsExceptions::InvalidQueryParameter }

  describe '#check_compliance!' do
    it 'should raise a runtime error when test is all lowercase' do
      expect { JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(rp) }.to raise_error error_class
    end
    
    it 'should return nil when test has a non a-z character' do
      expect(JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(rpa)).to be nil
      expect(JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(rpb)).to be nil
      expect(JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(rpc)).to be nil
    end

    it 'should work given an empty rack_req_params' do
      expect(JSONAPI::Exceptions::QueryParamsExceptions.check_compliance({})).to be nil
    end
    
    it 'should work given a rack_req_params w no impl specific params' do
      expect(JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(no_impl_sp_p)).to be nil
    end

    it 'should work given a rack_req_params w only impl specific params' do
      expect(JSONAPI::Exceptions::QueryParamsExceptions.check_compliance(only_impl_sp_p)).to be nil
    end

  end
end
