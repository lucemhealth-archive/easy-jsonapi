# frozen_string_literal: true

require 'rack/jsonapi/document/resource/attributes/attribute'
require 'shared_examples/name_value_and_query_shared_tests'

describe JSONAPI::Document::Resource::Attributes::Attribute do
  
  let(:pair) { JSONAPI::Document::Resource::Attributes::Attribute.new(:name, 'value') }
  let(:name) { 'name' }
  let(:value) { 'value' }
  let(:new_value) { 'new_value' }
  let(:to_str_orig) { "\"name\": \"value\"" }
  let(:name_error_msg) { 'Cannot change the name of an Attribute' } # this is what makes this class unique
  
  it_behaves_like 'name value and query shared tests' do
  end

  it 'should have a to_h method' do
    expect(pair.to_h).to eq({ name.to_sym => value })
  end
end
