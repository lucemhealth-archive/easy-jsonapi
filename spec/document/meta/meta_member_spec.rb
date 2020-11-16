# frozen_string_literal: true

require 'rack/jsonapi/document/meta/meta_member'
require 'shared_examples/name_value_pair_tests'

describe JSONAPI::Document::Meta::MetaMember do
  it_behaves_like 'name value pair tests' do
    let(:pair) { JSONAPI::Document::Meta::MetaMember.new(:name, 'value') }
  end
end
