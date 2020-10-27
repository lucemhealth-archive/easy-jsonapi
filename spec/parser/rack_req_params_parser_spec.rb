# frozen_string_literal: true

require 'rack/jsonapi/parser/rack_req_params_parser'

describe JSONAPI::Parser::RackReqParamsParser do

  before do
    rack_params = 
      {
        'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
        'include' => 'author, comments.author',
        'josh_ua' => 'demoss',
        'page' => { 'offset' => '1', 'limit' => '1' },
        'filter' => 'f',
        'sort' => 's'
      }
    
    @query_param_collection = JSONAPI::Parser::RackReqParamsParser.parse!(rack_params)
  end

  # The query_param collection when the parser is passed params
  let(:pc) { @query_param_collection }

  # The query_param collection when the parser is passed an empty query_param object
  let(:epc) { JSONAPI::Parser::RackReqParamsParser.parse!({}) }

  describe '#parse' do
    it 'should return a QueryParamCollection object' do
      expect(pc.class).to eq JSONAPI::Request::QueryParamCollection
    end

    it 'should return an empty QueryParamCollection when no params given' do
      expect(epc.empty?).to be true
    end

    it 'should return a QueryParamCollection when params given' do
      expect(pc.empty?).to be false
    end

    it 'should include each added item' do
      expect(pc.include?(:'fields[articles]')).to be true
      expect(pc.include?(:'fields[people]')).to be true
      expect(pc.include?(:include)).to be true
      expect(pc.include?(:josh_ua)).to be true
      expect(pc.include?(:page)).to be true
      expect(pc.include?(:filter)).to be true
      expect(pc.include?(:sort)).to be true
    end

    it 'should contain proper classes for each item in the param collection' do
      expect(pc.get(:'fields[articles]').class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Field
      expect(pc.get(:'fields[people]').class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Field
      expect(pc.get(:include).class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Include
      expect(pc.get(:josh_ua).class).to be JSONAPI::Request::QueryParamCollection::QueryParam
      expect(pc.get(:page).class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Page
      expect(pc.get(:filter).class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Filter
      expect(pc.get(:sort).class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Sort
    end

    it 'should raise InvalidParameter if given a impl specific param that does not follow naming rules' do
      p = JSONAPI::Request::QueryParamCollection::QueryParam.new(:joshua, 'demoss')
      pc.add(p)
      i = pc.get(:joshua)
      pp i.class
    end
  end
end
