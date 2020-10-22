# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param'

describe JSONAPI::Item do

  let(:obj) { { name: 'include', value: 'author,comments.likes' } }

  let(:i) { JSONAPI::Item.new(obj) }

  describe '#initialize' do

    it 'should create instance variables and accessor methods dynamically' do
      expect(i.instance_variables).to eq %i[@item]
      
      expect(i.name).to eq 'include'
      expect(i.value).to eq 'author,comments.likes'
      
      i.name = 'new_name'
      i.value = 'new_val'
      expect(i.name).to eq 'new_name'
      expect(i.value).to eq 'new_val'
    end
  end

  describe '#to_s' do
    it 'should represent a generic item logically' do
      expect(i.to_s).to eq "{ name => 'include', value => 'author,comments.likes' }"
    end
  end
end
