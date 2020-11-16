# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/page_param'
require 'shared_examples/name_value_pair_tests'

describe JSONAPI::Request::QueryParamCollection::PageParam do
  
  let(:p) { JSONAPI::Request::QueryParamCollection::PageParam.new(offset: 2, limit: 3) }
  
  it 'should have proper accessor methods' do
    expect(p.name).to eq 'page'
    expect(p.offset).to eq 2
    expect(p.limit).to eq 3
    p.offset = 4
    p.limit = 6
    expect(p.offset).to eq 4
    expect(p.limit).to eq 6
  end

  it 'should raise when calling #name=, #value, or #value=' do
    error_msg = 'Cannot change the name of QueryParam Objects'
    expect { p.name = 'new_name' }.to raise_error error_msg
    
    error_msg = 'PageParam does not provide a #value method, try #offset or #limit instead'
    expect { p.value }.to raise_error error_msg
    
    error_msg = 'PageParam does not provide a #value= method, try #offset= or #limit= instead'
    expect { p.value = 'new_value' }.to raise_error error_msg
  end

  it 'should have a working #to_s method' do
    expect(p.to_s).to eq 'page[offset]=2&page[limit]=3'
  end

end
