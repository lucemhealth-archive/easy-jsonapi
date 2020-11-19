# frozen_string_literal: true

require 'rack/jsonapi/document/links/link'
require 'shared_examples/name_value_pair_tests'

describe JSONAPI::Document::Links::Link do
  it_behaves_like 'name value pair tests' do
    let(:pair) { JSONAPI::Document::Links::Link.new(:name, 'value') }
    let(:name_error_msg) { 'Cannot change the name of a NameValuePair Object' }
  end
end
