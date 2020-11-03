# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param_collection/query_param'

describe JSONAPI::Request::QueryParamCollection::QueryParam do
  
  let(:p1) { JSONAPI::Request::QueryParamCollection::QueryParam.new('te_st', 'ing') }

  describe '#initialize' do

    it 'should have accessor methods for name & value' do
      expect(p1.name).to eq 'te_st'
      expect(p1.value).to eq ['ing']
      p1.name = 'new_name'
      p1.value = 'new_value'
      expect(p1.name).to eq 'new_name'
      expect(p1.value).to eq ['new_value']
    end

    it 'should have a working #to_s' do
      expect(p1.to_s).to eq "{ \"te_st\": \"ing\" }"
    end
  end
end
