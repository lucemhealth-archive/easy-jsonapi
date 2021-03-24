# frozen_string_literal: true

require 'easy/jsonapi/request/query_param_collection/fields_param/fieldset'
require 'easy/jsonapi/field'

describe JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset do

  let(:fieldset1) do
    JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new(
      'articles', 
      [
        JSONAPI::Field.new('title'), 
        JSONAPI::Field.new('body'),
        JSONAPI::Field.new('author')
      ]
    )
  end

  let(:fieldset2) do
    JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new(
      'people', 
      [
        JSONAPI::Field.new('name')
      ]
    )
  end

  context 'when initializing' do
    it 'should have proper reader methods' do
      expect(fieldset1.resource_type).to eq 'articles'
      expect(fieldset2.resource_type).to eq 'people'

      expect(fieldset1.fields.size).to eq 3
      expect(fieldset2.fields.size).to eq 1
    end

    it 'should raise when trying to overwrite instance variables' do
      expect { fieldset1.resource_type = 'new_type' }.to raise_error NoMethodError
      expect { fieldset2.resource_type = 'new_type' }.to raise_error NoMethodError
      expect { fieldset1.fields = 'new_fields' }.to raise_error NoMethodError
      expect { fieldset2.fields = 'new_fields' }.to raise_error NoMethodError
    end
  end

  context 'when checking to_s' do
    it 'should represent an individual fields query string' do
      expect(fieldset1.to_s).to eq 'fields[articles]=title,body,author'
      expect(fieldset2.to_s).to eq 'fields[people]=name'
    end
  end
end
