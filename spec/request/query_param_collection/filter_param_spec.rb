# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/filter_param'
require 'rack/jsonapi/request/query_param_collection/filter_param/filter'
require 'shared_examples/query_param_tests'

describe JSONAPI::Request::QueryParamCollection::FilterParam do
  
  it_behaves_like 'query param tests' do
    
    filter1 = JSONAPI::Request::QueryParamCollection::FilterParam::Filter.new('comments', '(date == today)')
    filter2 = JSONAPI::Request::QueryParamCollection::FilterParam::Filter.new('users', '(age < 15)')
    new_filter = JSONAPI::Request::QueryParamCollection::FilterParam::Filter.new('users', '(age > 15)')
    
    let(:pair) { JSONAPI::Request::QueryParamCollection::FilterParam.new([filter1, filter2]) }
    let(:name) { 'filters' }
    let(:value) { [filter1, filter2] }
    let(:new_value_input) { new_filter }
    let(:new_value) { [new_filter] }
    let(:to_str_orig) { 'filter[comments]=(date == today)&filter[users]=(age < 15)' }
  end
end
