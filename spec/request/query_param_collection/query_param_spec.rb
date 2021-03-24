# frozen_string_literal: true

require 'easy/jsonapi/item'
require 'easy/jsonapi/request/query_param_collection/query_param'
require 'shared_examples/query_param_tests'

describe JSONAPI::Request::QueryParamCollection::QueryParam do
  
  let(:p1) { JSONAPI::Request::QueryParamCollection::QueryParam.new('te_st', 'ing') }

  it_behaves_like 'query param tests' do
    let(:pair) { p1 }
    let(:name) { 'te_st' }
    let(:value) { ['ing'] }
    let(:new_value_input) { 'new_value' }
    let(:new_value) { ['new_value'] }
    let(:to_str_orig) { 'te_st=ing' }
  end
end
