# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/fields_param'
require 'rack/jsonapi/request/query_param_collection/fields_param/fieldset'
require 'rack/jsonapi/document/resource/field'

require 'shared_examples/name_value_pair_classes_tests'

describe JSONAPI::Request::QueryParamCollection::FieldsParam do

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

  let(:fieldset1) { JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new('articles', res_field_arr1) }
  let(:fieldset2) { JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new('people', res_field_arr2) }
  
  # Used when checking #value=
  res_field = JSONAPI::Document::Resource::Field.new('date')
  let(:fieldset3) { JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new('comments', res_field) }


  it_behaves_like 'name value pair classes' do
    let(:pair) { JSONAPI::Request::QueryParamCollection::FieldsParam.new([fieldset1, fieldset2]) }
    let(:name) { 'fields' }
    let(:value) { [fieldset1, fieldset2] }
    let(:new_value_input) { fieldset3 }
    let(:new_value) { [fieldset3] }
    let(:to_str_orig) { 'fields[articles]=title,body&fields[people]=name' }
  end
end
