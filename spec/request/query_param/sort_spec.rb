# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param'
require 'rack/jsonapi/request/query_param/sort'

describe JSONAPI::Request::QueryParam::Sort do
  
  let(:s1) { JSONAPI::Request::QueryParam::Sort.new('ing,ang') }

  describe '#initialize' do

    it 'should have instance variables: @name & @value' do
      expect(s1.name).to eq 'sort'
      expect(s1.value).to eq ['ing', 'ang']
    end

    it 'should have a working #to_s' do
      expect(s1.to_s).to eq "{ 'sort' => 'ing,ang' }"
    end

    it 'should not respond to #name=' do
      expect { s1.name = 'new_name' }.to raise_error 'Cannot set the name of a Sort object'
    end
  end
end
