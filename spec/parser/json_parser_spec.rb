# frozen_string_literal: true

require 'easy/jsonapi/exceptions'
require 'easy/jsonapi/parser/json_parser'
require 'oj'

describe JSONAPI::Parser::JSONParser do
  let(:hash1) { { data: { type: 'person', id: '123' } } }

  describe '#parse' do
    it 'should parse valid json into a hash' do
      hash = {}
      expect(JSONAPI::Parser::JSONParser.parse('{}')).to eq hash
      expect(JSONAPI::Parser::JSONParser.parse('{ "data": { "type": "person", "id": "123" } }')).to eq hash1
    end

    it 'should raise JSONAPI::Exceptions::JSONParseError when invalid input' do
      err_class = JSONAPI::Exceptions::JSONParseError
      expect { JSONAPI::Parser::JSONParser.parse('{ase') }.to raise_error err_class
    end
  end

  describe '#dump' do
    it 'should return valid JSON from a given ruby hash' do
      expect(JSONAPI::Parser::JSONParser.dump(hash1)).to eq Oj.dump(hash1, mode: :compat)
    end
  end
  
end
