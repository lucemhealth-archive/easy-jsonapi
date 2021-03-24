# frozen_string_literal: true

require 'easy/jsonapi/document/jsonapi/jsonapi_member'
require 'easy/jsonapi/document/meta/meta_member'
require 'shared_examples/document_collections'

describe JSONAPI::Document::Jsonapi do
  let(:item_class) { JSONAPI::Document::Jsonapi::JsonapiMember }
  
  meta = JSONAPI::Document::Meta::MetaMember.new('count', '1')
  jsonapi_member_arr = [
    JSONAPI::Document::Jsonapi::JsonapiMember.new('version', '1.0'),
    JSONAPI::Document::Jsonapi::JsonapiMember.new('meta', meta)
  ]

  let(:c) { JSONAPI::Document::Jsonapi.new(jsonapi_member_arr, &:name) }
  let(:ec) { JSONAPI::Document::Jsonapi.new }

  let(:c_size) { 2 }
  let(:keys) { %i[version meta] }
  let(:ex_item_key) { :version }
  let(:ex_item) { JSONAPI::Document::Jsonapi::JsonapiMember.new('version', '1.0') }
  
  let(:to_string) do
    '{ ' \
      "\"version\": \"1.0\", " \
      "\"meta\": { " \
        "\"count\": \"1\" " \
      '} ' \
    '}'
  end

  let(:to_hash) do
    {
      version: '1.0',
      meta: { count: '1' }
    }
  end

  it_behaves_like 'document collections'
end
