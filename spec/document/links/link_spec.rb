# frozen_string_literal: true

require 'rack/jsonapi/document/links/link'
require 'shared_examples/name_value_pair_classes_tests'

describe JSONAPI::Document::Links::Link do
  it_behaves_like 'name value pair classes' do
    let(:pair) { JSONAPI::Document::Links::Link.new(:name, 'value') }
  end
end
