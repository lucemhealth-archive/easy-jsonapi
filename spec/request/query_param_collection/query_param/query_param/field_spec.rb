# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param_collection/query_param'
require 'rack/jsonapi/request/query_param_collection/query_param/field'
require 'rack/jsonapi/document/resource/field'

describe JSONAPI::Request::QueryParamCollection::QueryParam::Field do
  let(:res_field_arr1) do
    [
      JSONAPI::Document::Resource::Field.new('title'), 
      JSONAPI::Document::Resource::Field.new('body')
    ]
  end

  let(:res_field_arr2) do
    [
      JSONAPI::Document::Resource::Field.new('name')
    ]
  end

  let(:f1) { JSONAPI::Request::QueryParamCollection::QueryParam::Field.new('articles', res_field_arr1) }

  let(:f2) { JSONAPI::Request::QueryParamCollection::QueryParam::Field.new('people', res_field_arr2) }

  describe '#initialize' do

    it 'should have proper accessor methods' do
      # resource testing
      expect(f1.resource).to eq 'articles'
      expect(f2.resource).to eq 'people'
      f1.resource = 'not_articles'
      f2.resource = 'not_people'
      expect(f1.resource).to eq 'not_articles'
      expect(f2.resource).to eq 'not_people'

      
      # fields testing
      expect(f1.fields).to eq res_field_arr1
      expect(f2.fields).to eq res_field_arr2
      new_res_field = JSONAPI::Document::Resource::Field.new('testing')
      f1.fields = new_res_field
      expect(f1.fields).to eq [new_res_field]
    end

    it 'should have a working #to_s' do
      expect(f1.to_s).to eq "fields[articles] => { \"articles\": \"title,body\" }"
      expect(f2.to_s).to eq "fields[people] => { \"people\": \"name\" }"
    end

    it 'should not respond to #name=, #value, or #value=' do
      expect(f1.name).to eq 'fields[articles]'
      expect { f1.name = 'new_name' }.to raise_error 'Cannot set the name of a Field object'
      expect { f1.value }.to raise_error 'Field objects do not have a value method, try #resource or #fields'
      expect { f1.value = 'new_value' }.to raise_error 'Cannot set value of Field object, becausee Field does not have a value'
    end
  end
end
