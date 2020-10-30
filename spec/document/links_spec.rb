# frozen_string_literal: true

require 'rack/jsonapi/document/links/link'
require_relative '../collection_subclasses_shared_tests'

describe JSONAPI::Document::Links do
  it_behaves_like 'collection like classes' do
    let(:item_class) { JSONAPI::Document::Links::Link }
    
    obj_arr = [
      { name: "self", value: "http://example.com/articles" },
      { name: "next", value: "http://example.com/articles?page[offset]=2" },
      { name: "last", value: "http://example.com/articles?page[offset]=10" }
    ]

    let(:c_size) { 3 }
    let(:keys) { %i[self next last] }
    let(:ex_item_key) { :self }
    let(:ex_item_value) { "http://example.com/articles" }
    
    let(:to_string) do
      '{ ' \
      "\"self\": \"http://example.com/articles\", " \
      "\"next\": \"http://example.com/articles?page[offset]=2\", " \
      "\"last\": \"http://example.com/articles?page[offset]=10\"" \
      ' }'
    end

    item_arr = obj_arr.map do |i|
      JSONAPI::Document::Links::Link.new(i[:name], i[:value])
    end
    let(:c) { JSONAPI::Document::Links.new(item_arr, &:name) }
    let(:ec) { JSONAPI::Document::Links.new }
    
  end
end
