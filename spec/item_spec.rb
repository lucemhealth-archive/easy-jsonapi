# frozen_string_literal: true

require 'easy/jsonapi/item'
require 'shared_examples/item_shared_tests'

describe JSONAPI::Item do
  it_behaves_like 'item shared tests' do
    let(:item) { JSONAPI::Item.new({ name: 'name', value: 'value' }) }
  end
end
