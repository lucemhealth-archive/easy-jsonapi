# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/sort_param'
require 'rack/jsonapi/document/resource/field'
require 'shared_examples/name_value_pair_classes_tests'

describe JSONAPI::Request::QueryParamCollection::SortParam do
  
  it_behaves_like 'name value pair classes' do
    res_field1 = JSONAPI::Document::Resource::Field.new('age')
    res_field2 = JSONAPI::Document::Resource::Field.new('title')
    
    let(:pair) { JSONAPI::Request::QueryParamCollection::SortParam.new([res_field1, res_field2]) }
    let(:name) { 'sort' }
    let(:value) { [res_field1, res_field2] }

    res_field3 = JSONAPI::Document::Resource::Field.new('name')
    let(:new_value_input) { [res_field3] }
    let(:new_value) { [res_field3] }
    let(:to_str_orig) { 'sort=age,title' }
  end
end
