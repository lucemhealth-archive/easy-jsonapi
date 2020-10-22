# frozen_string_literal: true

require 'rack/jsonapi/parser/rack_req_params_parser'

describe JSONAPI::Parser::RackReqParamsParser do

  before do
    rack_params = 
      {
        'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
        'include' => 'author, comments.author',
        'josh_ua' => 'demoss',
        'page' => { 'offset' => '1', 'limit' => '1' }
      }
    
    @param_collection = JSONAPI::Parser::RackReqParamsParser.parse!(rack_params)
  end

  # The param collection when the parser is passed params
  let(:pc) { @param_collection }

  # The param collection when the parser is passed an empty param object
  let(:epc) { JSONAPI::Parser::RackReqParamsParser.parse!({}) }

  describe '#parse' do
    it 'should return a ParamCollection object' do
      expect(pc.class).to eq JSONAPI::Collection::ParamCollection
    end

    it 'should return an empty ParamCollection when no params given' do
      expect(epc.empty?).to be true
    end

    it 'should return a ParamCollection when params given' do
      expect(pc.empty?).to be false
    end
  end

  describe '#init_a_param' do
    # it 'should create 5 param objects from pc' do
    #   expect(pc.size).to eq 5
    # end
  end
end
