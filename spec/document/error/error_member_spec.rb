# frozen_string_literal: true

require 'rack/jsonapi/document/error/error_member'
require 'shared_examples/name_value_pair_classes_tests'

describe JSONAPI::Document::Error::ErrorMember do
  it_behaves_like 'name value pair classes' do
    let(:pair) { JSONAPI::Document::Error::ErrorMember.new(:name, 'value') }
  end
end
