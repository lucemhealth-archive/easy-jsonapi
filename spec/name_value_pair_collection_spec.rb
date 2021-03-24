# frozen_string_literal: true

require 'easy/jsonapi/name_value_pair_collection'
require 'easy/jsonapi/name_value_pair'
require 'shared_examples/name_value_pair_collections'

describe JSONAPI::NameValuePairCollection do
  let(:item_class) { JSONAPI::NameValuePair }
  let(:c_size) { 5 }
  let(:keys) { %i[includes lebron charles michael kobe] }
  let(:ex_item_key) { :includes }
  let(:ex_item) { JSONAPI::NameValuePair.new(:includes, 'author,comments.likes') }

  let(:to_string) do
    '{ ' \
      "\"includes\": \"author,comments.likes\", " \
      "\"lebron\": \"james\", " \
      "\"charles\": \"barkley\", " \
      "\"michael\": \"jordan,jackson\", " \
      "\"kobe\": \"bryant\"" \
    ' }'
  end

  let(:to_hash) do
    {
      includes: 'author,comments.likes',
      lebron: 'james',
      charles: 'barkley',
      michael: 'jordan,jackson',
      kobe: 'bryant'
    }
  end

  obj_arr = {
    includes: 'author,comments.likes',
    lebron: 'james',
    charles: 'barkley',
    michael: 'jordan,jackson',
    kobe: 'bryant'
  }

  pair_arr = obj_arr.map { |k, v| JSONAPI::NameValuePair.new(k, v) }
  let(:c) { JSONAPI::NameValuePairCollection.new(pair_arr) }
  let(:ec) { JSONAPI::NameValuePairCollection.new }

  it_behaves_like 'name value pair collections'

  context 'when checking dynamic accessor methods' do
    it 'should be able to access items by their names' do
      expect(c.includes).to eq 'author,comments.likes'
      expect(c.lebron).to eq 'james'
      expect(c.charles).to eq 'barkley'
      expect(c.michael).to eq 'jordan,jackson'
      expect(c.kobe).to eq 'bryant'
    end
  end

  context 'when checking if items are case insensitive' do
    it 'should treat cases differently' do
      expect(c.get('includes').class).to eq JSONAPI::NameValuePair
      expect(c.get('INCLUDES').class).to eq NilClass
    end
    it 'should be symbol/string insensitive though' do
      i1 = c.get('includes')
      i3 = c.get(:includes)
      expect(i1).to eq i3
    end
  end
end
