# frozen_string_literal: true

require 'shared_examples/name_value_and_query_shared_tests'

shared_examples 'query param tests' do
  it_behaves_like 'name value and query shared tests' do
    let(:name_error_msg) { 'Cannot change the name of QueryParam Objects' }
  end
end
