# frozen_string_literal: true

require 'easy/jsonapi/request/query_param_collection/sort_param'
require 'easy/jsonapi/field'
require 'shared_examples/query_param_tests'

describe JSONAPI::Request::QueryParamCollection::SortParam do
  
  it_behaves_like 'query param tests' do
    res_field1 = JSONAPI::Field.new('age')
    res_field2 = JSONAPI::Field.new('title')
    
    let(:pair) { JSONAPI::Request::QueryParamCollection::SortParam.new([res_field1, res_field2]) }
    let(:name) { 'sorts' }
    let(:value) { [res_field1, res_field2] }

    res_field3 = JSONAPI::Field.new('name')
    let(:new_value_input) { [res_field3] }
    let(:new_value) { [res_field3] }
    let(:to_str_orig) { 'sort=age,title' }
  end
end
