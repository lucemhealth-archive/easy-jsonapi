# frozen_string_literal: true

require 'rack/jsonapi/document/resource/attributes/attribute'
require 'shared_examples/document_collections'

describe JSONAPI::Document::Resource::Attributes do
  let(:item_class) { JSONAPI::Document::Resource::Attributes::Attribute }
  
  obj_arr = [
    { name: 'name', value: 'john smith' },
    { name: 'height', value: 'six feet' },
    { name: 'sex', value: 'male' }
  ]
  
  let(:c_size) { 3 }
  let(:keys) { %i[name height sex] }
  let(:ex_item_key) { :name }
  let(:ex_item) { JSONAPI::Document::Resource::Attributes::Attribute.new('name', 'john smith') }
  
  let(:to_string) do
    "{ \"name\": \"john smith\", \"height\": \"six feet\", \"sex\": \"male\" }"
  end

  let(:to_hash) do
    { name: 'john smith', height: 'six feet', sex: 'male' }
  end

  item_arr = obj_arr.map do |i|
    JSONAPI::Document::Resource::Attributes::Attribute.new(i[:name], i[:value])
  end
  let(:c) { JSONAPI::Document::Resource::Attributes.new(item_arr, &:name) }
  let(:ec) { JSONAPI::Document::Resource::Attributes.new }
  
  it_behaves_like 'document collections'
end
