# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'shared_examples/item_like_classes_tests'

describe JSONAPI::Item do
  it_behaves_like 'item like classes' do
    let(:item) { JSONAPI::Item.new({ name: 'name', value: 'value' }) }
  end
    
  describe '#initialize' do
    it 'should raise if a hash is passed with strings as keys' do
      tmp = { 'name' => 'test', 'value' => 'ing' }
      expect { JSONAPI::Item.new(tmp) }.to raise_error "All keys must be Symbols. 'name' was String"
      tmp = { name: 'test', 'value' => 'ing' }
      expect { JSONAPI::Item.new(tmp) }.to raise_error "All keys must be Symbols. 'value' was String"
    end
  end
end
