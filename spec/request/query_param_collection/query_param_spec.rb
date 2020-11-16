# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param_collection/query_param'

describe JSONAPI::Request::QueryParamCollection::QueryParam do
  
  let(:p1) { JSONAPI::Request::QueryParamCollection::QueryParam.new('te_st', 'ing') }

  describe '#initialize' do

    it 'should have accessor methods for name & value' do
      expect(p1.name).to eq 'te_st'
      expect(p1.value).to eq ['ing']
      p1.value = 'new_value'
      expect(p1.value).to eq ['new_value']
    end

    it 'should raise if #name= is called' do
      expect {p1.name = 'new_name' }.to raise_error 'Cannot change the name of a QueryParam class'
    end

    it 'should have a working #to_s' do
      expect(p1.to_s).to eq "te_st=ing"
    end
  end
end
