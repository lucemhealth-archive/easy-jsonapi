# frozen_string_literal: true

require 'easy/jsonapi/request/query_param_collection/fields_param'
require 'easy/jsonapi/request/query_param_collection/fields_param/fieldset'
require 'easy/jsonapi/field'

require 'shared_examples/query_param_tests'

describe JSONAPI::Request::QueryParamCollection::FieldsParam do

  let(:res_field_arr1) do
    [
      JSONAPI::Field.new('title'), 
      JSONAPI::Field.new('body')
    ]
  end

  let(:res_field_arr2) do
    [
      JSONAPI::Field.new('name')
    ]
  end

  let(:fieldset1) { JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new('articles', res_field_arr1) }
  let(:fieldset2) { JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new('people', res_field_arr2) }
  
  # Used when checking #value=
  res_field = JSONAPI::Field.new('date')
  let(:fieldset3) { JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new('comments', res_field) }


  it_behaves_like 'query param tests' do
    let(:pair) { JSONAPI::Request::QueryParamCollection::FieldsParam.new([fieldset1, fieldset2]) }
    let(:name) { 'fields' }
    let(:value) { [fieldset1, fieldset2] }
    let(:new_value_input) { fieldset3 }
    let(:new_value) { [fieldset3] }
    let(:to_str_orig) { 'fields[articles]=title,body&fields[people]=name' }
  end
end
