# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/item/query_param'
require 'rack/jsonapi/item/query_param/filter'

describe JSONAPI::Item::QueryParam::Filter do
  
  let(:f1) { JSONAPI::Item::QueryParam::Filter.new('ing,ang') }

  describe '#initialize' do

    it 'should have instance variables: @name & @value' do
      expect(f1.name).to eq 'filter'
      expect(f1.value).to eq ['ing', 'ang']
    end

    it 'should have a working #to_s' do
      expect(f1.to_s).to eq "{ 'filter' => 'ing,ang' }"
    end

    it 'should not respond to #name=' do
      expect { f1.name = 'new_name' }.to raise_error 'Cannot set the name of a Filter object'
    end
  end
end
