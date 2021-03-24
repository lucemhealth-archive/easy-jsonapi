# frozen_string_literal: true

require 'easy/jsonapi/document/resource/attributes/attribute'
require 'shared_examples/name_value_pair_tests'

describe JSONAPI::Document::Resource::Attributes::Attribute do
  
  let(:pair) { JSONAPI::Document::Resource::Attributes::Attribute.new(:name, 'value') }
  
  it_behaves_like 'name value pair tests'

  describe 'when testing field instance variable' do
    it 'should be a JSONAPI::Field' do
      expect(pair.field.class).to eq JSONAPI::Field
    end

    it 'should have the same name as the attributes' do
      expect(pair.name).to eq pair.field.name
    end

    it 'should have the right type' do
      expect(pair.field.type).to eq String
    end
  end
end
