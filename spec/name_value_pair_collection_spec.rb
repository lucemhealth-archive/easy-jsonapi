# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/name_value_pair'
require 'shared_examples/name_value_pair_collections'

describe JSONAPI::NameValuePairCollection do
  let(:item_class) { JSONAPI::NameValuePair }
  let(:c_size) { 5 }
  let(:keys) { %i[include lebron charles michael kobe] }
  let(:ex_item_key) { :include }
  let(:ex_item) { JSONAPI::NameValuePair.new(:include, 'author,comments.likes') }

  let(:to_string) do
    '{ ' \
      "\"include\": \"author,comments.likes\", " \
      "\"lebron\": \"james\", " \
      "\"charles\": \"barkley\", " \
      "\"michael\": \"jordan,jackson\", " \
      "\"kobe\": \"bryant\"" \
    ' }'
  end

  let(:to_hash) do
    {
      include: 'author,comments.likes',
      lebron: 'james',
      charles: 'barkley',
      michael: 'jordan,jackson',
      kobe: 'bryant'
    }
  end

  obj_arr = {
    include: 'author,comments.likes',
    lebron: 'james',
    charles: 'barkley',
    michael: 'jordan,jackson',
    kobe: 'bryant'
  }

  pair_arr = obj_arr.map { |k, v| JSONAPI::NameValuePair.new(k, v) }
  let(:c) { JSONAPI::NameValuePairCollection.new(pair_arr) }
  let(:ec) { JSONAPI::NameValuePairCollection.new }

  it_behaves_like 'name value pair collections' do
  end
end
