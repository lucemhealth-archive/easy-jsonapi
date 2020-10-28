# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param_collection/query_param'
require 'rack/jsonapi/request/query_param_collection/query_param/include'

describe JSONAPI::Request::QueryParamCollection::QueryParam::Include do
  
  let(:i1) { JSONAPI::Request::QueryParamCollection::QueryParam::Include.new('author') }
  let(:i2) { JSONAPI::Request::QueryParamCollection::QueryParam::Include.new('comments.author') }
  let(:i3) { JSONAPI::Request::QueryParamCollection::QueryParam::Include.new(['comments', 'likes', 'users']) }

  describe '#initialize' do

    it 'should have proper accessor methods' do
      expect(i1.name).to eq 'include'
      expect(i1.resource).to eq ['author']
      
      expect(i2.resource).to eq ['comments', 'author']
      
      expect(i3.resource).to eq ['comments', 'likes', 'users']
    end

    it 'should have a working #to_s' do
      expect(i1.to_s).to eq "{ 'include' => 'author' }"
      expect(i2.to_s).to eq "{ 'include' => 'comments.author' }"
      expect(i3.to_s).to eq "{ 'include' => 'comments.likes.users' }"
    end

    it 'should not respond to #name=, #value, or #value=' do
      expect(i1.name).to eq 'include'
      expect { i1.name = 'new_name' }.to raise_error 'Cannot set the name of a Include object'
      expect { i1.value }.to raise_error 'Include objects do not have a value method, try #resource'
      expect { i1.value = 'new_value' }.to raise_error 'Cannot set value of Include object, becausee Include does not have a value'
    end
  end
end
