# frozen_string_literal: true

require 'rack/jsonapi/header_collection'
require 'rack/jsonapi/header_collection/header'
require 'collection_subclasses_shared_tests'

describe JSONAPI::HeaderCollection do
  it_behaves_like 'collection like classes' do
    let(:item_class) { JSONAPI::HeaderCollection::Header }
    
    obj_arr = [
      { name: 'Content-Type', value: 'application/vnd.api+json' },
      { name: 'Accept', value: 'application/vnd.api+json, text/plain, text/html ; level=1 ; q=0.5, text/x-div; q=0.8, text/x-c, */*' },
      { name: 'Host', value: 'localhost:9292' },
      { name: 'Connection', value: 'keep-alive' },
      { name: 'WWW-Authenticate', value: 'Basic realm="Access to the staging site", charset="UTF-8"' }
    ]
    
    let(:c_size) { 5 }
    let(:keys) { %i[content-type accept host connection www-authenticate] }
    let(:ex_item_key) { :'content-type' }
    let(:ex_item_value) { 'application/vnd.api+json' }
    
    let(:to_string) do
      '{ ' \
      "\"Content-Type\": \"application/vnd.api+json\", " \
      "\"Accept\": \"application/vnd.api+json, text/plain, text/html ; level=1 ; q=0.5, text/x-div; q=0.8, text/x-c, */*\", " \
      "\"Host\": \"localhost:9292\", " \
      "\"Connection\": \"keep-alive\", " \
      "\"WWW-Authenticate\": \"Basic realm=\"Access to the staging site\", charset=\"UTF-8\"\"" \
      ' }'
    end

    item_arr = obj_arr.map do |i|
      JSONAPI::HeaderCollection::Header.new(i[:name], i[:value])
    end
    let(:c) { JSONAPI::HeaderCollection.new(item_arr, &:name) }
    let(:ec) { JSONAPI::HeaderCollection.new }
    
  end
end
