# frozen_string_literal: true

require 'rack/jsonapi/document/data/resource/attributes/attribute'
require 'collection/helper_spec'

describe JSONAPI::Document::Data::Resource::Attributes do
  it_behaves_like 'collection like classes' do
    let(:item_class) { JSONAPI::Document::Data::Resource::Attributes::Attribute }
    
    obj_arr = [
      { name: 'name', value: 'john smith' },
      { name: 'height', value: 'six feet' },
      { name: 'sex', value: 'male' }
    ]
    
    let(:c_size) { 3 }
    let(:keys) { %i[name height sex] }
    let(:ex_item_key) { :name }
    let(:ex_item_value) { 'john smith' }
    
    let(:to_string) do
      "{ name => { 'name' => 'john smith' }, height => { 'height' => 'six feet' }, sex => { 'sex' => 'male' } }"
    end

    item_arr = obj_arr.map do |i|
      JSONAPI::Document::Data::Resource::Attributes::Attribute.new(i[:name], i[:value])
    end
    let(:c) { JSONAPI::Document::Data::Resource::Attributes.new(item_arr, &:name) }
    let(:ec) { JSONAPI::Document::Data::Resource::Attributes.new }
    
  end
end
