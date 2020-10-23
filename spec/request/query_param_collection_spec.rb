# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/request/query_param_collection'

require 'rack/jsonapi/request/query_param_collection/query_param/include'

require 'rack/jsonapi/document/data/resource/field'

require 'collection_subclasses_shared_tests'

describe JSONAPI::Request::QueryParamCollection do

  item_arr = 
      [
        JSONAPI::Request::QueryParamCollection::QueryParam::Include.new('author,comments.likes'),
        JSONAPI::Request::QueryParamCollection::QueryParam::Field.new(
          'articles', 
          [
            JSONAPI::Document::Data::Resource::Field.new('title', nil), 
            JSONAPI::Document::Data::Resource::Field.new('body', nil)
          ]
        ),
        JSONAPI::Request::QueryParamCollection::QueryParam::Field.new(
          'people', 
          [
            JSONAPI::Document::Data::Resource::Field.new('name', nil)
          ]
        ),
        JSONAPI::Request::QueryParamCollection::QueryParam.new('leBron', 'james'),
        JSONAPI::Request::QueryParamCollection::QueryParam::Page.new(3, 25),
        JSONAPI::Request::QueryParamCollection::QueryParam::Sort.new('alpha'),
        JSONAPI::Request::QueryParamCollection::QueryParam::Filter.new('special')
      ]

  it_behaves_like 'collection like classes' do
    
    # rack::request.params:
    # {
    #   "include"=>"author, comments.author",
    #   "fields"=>{"articles"=>"title,body,author", "people"=>"name"},
    #   "josh_ua"=>"demoss",
    #   "page"=>{"offset"=>"1", "limit"=>"1"},
    #   "sort"=>"alpha",
    #   "filter"=>"special",
    # }
    
    let(:item_class) { JSONAPI::Request::QueryParamCollection::QueryParam }
    let(:c_size) { 7 }
    let(:keys) { %i[include fields[articles] fields[people] lebron page sort filter] }
    let(:ex_item_key) { :include }
    let(:ex_item_value) { 'author,comments.likes' }
    
    let(:to_string) do
      '{ ' \
        "include => { 'include' => 'author,comments.likes' }, " \
        "fields[articles] => { fields[articles] => { 'articles' => 'title,body' } }, " \
        "fields[people] => { fields[people] => { 'people' => 'name' } }, " \
        "lebron => { 'leBron' => 'james' }, " \
        "page => { page => { 'offset' => '3', 'limit' => '25' } }, " \
        "sort => { 'sort' => 'alpha' }, " \
        "filter => { 'filter' => 'special' }" \
      ' }'
    end

    let(:c) { JSONAPI::Request::QueryParamCollection.new(item_arr, &:name) }
    let(:ec) { JSONAPI::Request::QueryParamCollection.new }
    
  end

  describe '#method_missing' do

    let(:pc) { JSONAPI::Request::QueryParamCollection.new(item_arr, &:name) }
    
    def only_includes(query_param_collection, query_param)
      checker = true
      query_param_collection.each do |p|
        checker = (checker && p.class == query_param)  
      end
      checker
    end
    
    it 'should allow you to have dynamic methods for special params' do
      fields = pc.fields
      filters = pc.filters
      includes = pc.includes
      pages = pc.pages
      sorts = pc.sorts

      expect(fields.class).to eq JSONAPI::Request::QueryParamCollection
      expect(filters.class).to eq JSONAPI::Request::QueryParamCollection
      expect(includes.class).to eq JSONAPI::Request::QueryParamCollection
      expect(pages.class).to eq JSONAPI::Request::QueryParamCollection
      expect(sorts.class).to eq JSONAPI::Request::QueryParamCollection
      
      expect(only_includes(fields, JSONAPI::Request::QueryParamCollection::QueryParam::Field)).to eq true
      expect(only_includes(filters, JSONAPI::Request::QueryParamCollection::QueryParam::Filter)).to eq true
      expect(only_includes(includes, JSONAPI::Request::QueryParamCollection::QueryParam::Include)).to eq true
      expect(only_includes(pages, JSONAPI::Request::QueryParamCollection::QueryParam::Page)).to eq true
      expect(only_includes(sorts, JSONAPI::Request::QueryParamCollection::QueryParam::Sort)).to eq true

    end
  end
end
