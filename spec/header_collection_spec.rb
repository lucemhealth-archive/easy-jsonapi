# frozen_string_literal: true

require 'rack/jsonapi/header_collection'
require 'rack/jsonapi/header_collection/header'
require 'shared_examples/name_value_pair_collections'

describe JSONAPI::HeaderCollection do
  let(:item_class) { JSONAPI::HeaderCollection::Header }
  obj_arr = [
    { name: 'CONTENT_TYPE', value: 'application/vnd.api+json' },
    { name: 'ACCEPT', value: 'application/vnd.api+json, text/plain, text/html ; level=1 ; q=0.5, text/x-div; q=0.8, text/x-c, */*' },
    { name: 'HOST', value: 'localhost:9292' },
    { name: 'CONNECTION', value: 'keep-alive' },
    { name: 'WWW_AUTHENTICATE', value: 'Basic realm="Access to the staging site", charset="UTF-8"' }
  ]
  
  let(:c_size) { 5 }
  let(:keys) { %i[content_type accept host connection www_authenticate] }
  let(:ex_item_key) { :content_type }
  let(:ex_item) { JSONAPI::HeaderCollection::Header.new('content-type', 'application/vnd.api+json') }
  
  let(:to_string) do
    '{ ' \
    "\"CONTENT_TYPE\": \"application/vnd.api+json\", " \
    "\"ACCEPT\": \"application/vnd.api+json, text/plain, text/html ; level=1 ; q=0.5, text/x-div; q=0.8, text/x-c, */*\", " \
    "\"HOST\": \"localhost:9292\", " \
    "\"CONNECTION\": \"keep-alive\", " \
    "\"WWW_AUTHENTICATE\": \"Basic realm=\"Access to the staging site\", charset=\"UTF-8\"\"" \
    ' }'
  end

  item_arr = obj_arr.map do |i|
    JSONAPI::HeaderCollection::Header.new(i[:name], i[:value])
  end
  let(:c) { JSONAPI::HeaderCollection.new(item_arr, &:name) }
  let(:ec) { JSONAPI::HeaderCollection.new }
  
  it_behaves_like 'name value pair collections' do
  end

  context 'when checking dynamic access methods' do
    it 'should retrieve the value of the object specified' do
      expect(c.content_type).to eq obj_arr[0][:value]
      expect(c.accept).to eq obj_arr[1][:value]
      expect(c.host).to eq obj_arr[2][:value]
      expect(c.connection).to eq obj_arr[3][:value]
      expect(c.www_authenticate).to eq obj_arr[4][:value]
    end
  end

  context 'when checking if items are case insensitive' do
    it 'should be able to retrieve the same item with different case names' do
      i1 = c.get('host')
      i2 = c.get('HOST')
      expect(i1).to eq i2
      i3 = c.get(:host)
      expect(i1).to eq i3
    end
  end
end
