# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param_collection/query_param'
require 'shared_examples/name_value_pair_classes_tests'

describe JSONAPI::Request::QueryParamCollection::QueryParam do
  
  let(:p1) { JSONAPI::Request::QueryParamCollection::QueryParam.new('te_st', 'ing') }

  it_behaves_like 'name value pair classes' do
    let(:pair) { p1 }
    let(:name) { 'te_st' }
    let(:value) { ['ing'] }
    let(:new_value_input) { 'new_value' }
    let(:new_value) { ['new_value'] }
    let(:to_str_orig) { 'te_st=ing' }
    let(:name_error_msg) { 'Cannot change the name of a QueryParam class' }
  end
end
