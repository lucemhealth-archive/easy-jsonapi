# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/item/header'

describe JSONAPI::Item::Header do
  
  let(:p1) { JSONAPI::Item::Header.new('test', 'ing') }

  describe '#initialize' do

    it 'should have instance variables: @name & @value' do
      expect(p1.name).to eq 'test'
      expect(p1.value).to eq 'ing'
    end

    it 'should have a working #to_s' do
      expect(p1.to_s).to eq "{ 'test' => 'ing' }"
    end
  end
end
