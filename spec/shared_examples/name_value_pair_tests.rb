# frozen_string_literal: true

require 'shared_examples/name_value_and_query_shared_tests'

shared_examples 'name value pair tests' do
  it_behaves_like 'name value and query shared tests' do
    let(:name) { 'name' }
    let(:value) { 'value' }
    let(:new_value) { 'new_value' }
    let(:to_str_orig) { "\"name\": \"value\"" }
    let(:name_error_msg) { 'Cannot change the name of NameValuePair Objects' }
  end
end
