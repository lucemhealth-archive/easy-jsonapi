# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param_collection/query_param'
require 'rack/jsonapi/request/query_param_collection/query_param/page'

describe JSONAPI::Request::QueryParamCollection::QueryParam::Page do
  
  let(:pg1) { JSONAPI::Request::QueryParamCollection::QueryParam::Page.new(3, 25) }

  describe '#initialize' do

    it 'should have instance variables: @name & @value' do
      expect(pg1.offset).to eq 3
      expect(pg1.limit).to eq 25
      pg1.offset = 4
      pg1.limit = 26
      expect(pg1.offset).to eq 4
      expect(pg1.limit).to eq 26

    end
    
    it 'should have a working #to_s' do
      expect(pg1.to_s).to eq "{ page => { 'offset' => '3', 'limit' => '25' } }"
    end
    
    it 'should not respond to #name=, #value, or #value=' do
      expect(pg1.name).to eq 'page'
      expect { pg1.name = 'new_name' }.to raise_error 'Cannot set the name of a Page object'
      expect { pg1.value }.to raise_error 'Page objects do not have a value method, try #offset or #limit'
      expect { pg1.value = 'new_value' }.to raise_error 'Cannot set value of Page object, becausee Page does not have a value'
    end
  end
end
