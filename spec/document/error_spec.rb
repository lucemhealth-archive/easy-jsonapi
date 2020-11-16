# frozen_string_literal: true

require 'rack/jsonapi/document/error'
require 'rack/jsonapi/document/error/error_member'
require 'rack/jsonapi/document/meta/meta_member'
require 'rack/jsonapi/document/meta'
require 'rack/jsonapi/document/links/link'
require 'rack/jsonapi/document/links'
require 'shared_examples/collection_like_classes_tests'

describe JSONAPI::Document::Error do
  it_behaves_like 'collection-like classes' do
    let(:item_class) { JSONAPI::Document::Error::ErrorMember }

    meta_member_obj = JSONAPI::Document::Meta::MetaMember.new('count', '1')
    meta_obj = JSONAPI::Document::Meta.new([meta_member_obj])

    link_obj = JSONAPI::Document::Links::Link.new('related', 'url')
    links_obj = JSONAPI::Document::Links.new([link_obj])
    
    error_member_arr = [
      JSONAPI::Document::Error::ErrorMember.new('status', '422'),
      JSONAPI::Document::Error::ErrorMember.new('title', 'Invalid Attribute'),
      JSONAPI::Document::Error::ErrorMember.new('meta', meta_obj),
      JSONAPI::Document::Error::ErrorMember.new('links', links_obj)
    ]

    let(:c) { JSONAPI::Document::Error.new(error_member_arr, &:name) }
    let(:ec) { JSONAPI::Document::Error.new }

    let(:c_size) { 4 }
    let(:keys) { %i[status title meta links] }
    let(:ex_item_key) { :status }
    let(:ex_item) { JSONAPI::Document::Error::ErrorMember.new('status', '422') }
    
    let(:to_string) do
      '{ ' \
        "\"status\": \"422\", " \
        "\"title\": \"Invalid Attribute\", " \
        "\"meta\": { \"count\": \"1\" }, " \
        "\"links\": { \"related\": \"url\" } " \
      '}'
    end

    
  end
end
