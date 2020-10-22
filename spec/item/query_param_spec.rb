# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/item/query_param'

describe JSONAPI::Item::QueryParam do
  
  let(:p1) { JSONAPI::Item::QueryParam.new('test', 'ing') }

  describe '#initialize' do

    it 'should have accessor methods for name & value' do
      expect(p1.name).to eq 'test'
      expect(p1.value).to eq ['ing']
      p1.name = 'new_name'
      p1.value = 'new_value'
      expect(p1.name).to eq 'new_name'
      expect(p1.value).to eq ['new_value']
    end

    it 'should have a working #to_s' do
      expect(p1.to_s).to eq "{ 'test' => 'ing' }"
    end
  end
end
