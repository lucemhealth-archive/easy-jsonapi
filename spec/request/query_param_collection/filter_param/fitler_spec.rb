# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/filter_param/filter'

describe JSONAPI::Request::QueryParamCollection::FilterParam::Filter do

  let(:f) { JSONAPI::Request::QueryParamCollection::FilterParam::Filter.new('res_name', 'special') }

  context 'when initializing' do
    it 'should have proper reader methods' do
      expect(f.resource_type).to eq 'res_name'
      expect(f.filter_string).to eq 'special'
    end

    it 'should raise when trying to overwrite instance variables' do
      expect { f.resource_type = 'new_type' }.to raise_error NoMethodError
      expect { f.filter_string = 'new_string' }.to raise_error NoMethodError
    end
  end

  context 'when checking to_s' do
    it 'should represent an individual fields query string' do
      expect(f.to_s).to eq 'filter[res_name]=special'
    end
  end
end
