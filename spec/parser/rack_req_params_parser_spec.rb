# frozen_string_literal: true

require 'rack/jsonapi/parser/rack_req_params_parser'
require 'rack/jsonapi/exceptions/query_params_exceptions'

describe JSONAPI::Parser::RackReqParamsParser do

  before do
    rack_params = 
      {
        'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
        'include' => 'author, comments.likes',
        'josh_ua' => 'demoss',
        'page' => { 'offset' => '1', 'limit' => '1' },
        'filter' => 'f',
        'sort' => 's'
      }

    @rack_params_w_bad_name =
      {
        'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
        'include' => 'author, comments.likes',
        'joshua' => 'demoss',
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

  let(:e_class) { JSONAPI::Exceptions::QueryParamsExceptions::InvalidParameter }

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
      expect(pc.include?(:'include|author')).to be true
      expect(pc.include?(:'include|comments.likes')).to be true
      expect(pc.include?(:josh_ua)).to be true
      expect(pc.include?(:page)).to be true
      expect(pc.include?(:filter)).to be true
      expect(pc.include?(:sort)).to be true
    end

    it 'should contain proper classes for each item in the param collection' do
      expect(pc.get(:'fields[articles]').class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Field
      expect(pc.get(:'fields[people]').class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Field
      expect(pc.get(:'include|author').class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Include
      expect(pc.get(:'include|comments.likes').class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Include
      expect(pc.get(:josh_ua).class).to be JSONAPI::Request::QueryParamCollection::QueryParam
      expect(pc.get(:page).class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Page
      expect(pc.get(:filter).class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Filter
      expect(pc.get(:sort).class).to be JSONAPI::Request::QueryParamCollection::QueryParam::Sort
    end

    it 'should raise InvalidParameter if given a impl specific param that does not follow naming rules' do
      expect { JSONAPI::Parser::RackReqParamsParser.parse!(@rack_params_w_bad_name) }.to raise_error e_class
    end
  end
end
