# frozen_string_literal: true

require 'rack/jsonapi/document/jsonapi/jsonapi_member'
require 'shared_examples/name_value_pair_classes_tests'

describe JSONAPI::Document::Jsonapi::JsonapiMember do
  it_behaves_like 'name value pair classes' do
    let(:pair) { JSONAPI::Document::Jsonapi::JsonapiMember.new(:name, 'value') }
  end
end
