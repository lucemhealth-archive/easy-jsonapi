# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/request/query_param_collection'

require 'rack/jsonapi/request/query_param_collection/include_param'
require 'rack/jsonapi/request/query_param_collection/filter_param'
require 'rack/jsonapi/request/query_param_collection/page_param'
require 'rack/jsonapi/request/query_param_collection/sort_param'
require 'rack/jsonapi/request/query_param_collection/filter_param'

require 'rack/jsonapi/document/resource/field'

require 'shared_examples/collection_like_classes_tests'

describe JSONAPI::Request::QueryParamCollection do

  item_arr = 
    [
      JSONAPI::Request::QueryParamCollection::IncludeParam.new('author'),
      JSONAPI::Request::QueryParamCollection::IncludeParam.new('comments.likes'),
      JSONAPI::Request::QueryParamCollection::FieldsParam.new(
        'articles', 
        [
          JSONAPI::Document::Resource::Field.new('title'), 
          JSONAPI::Document::Resource::Field.new('body'),
          JSONAPI::Document::Resource::Field.new('author')
        ]
      ),
      JSONAPI::Request::QueryParamCollection::FieldsParam.new(
        'people', 
        [
          JSONAPI::Document::Resource::Field.new('name')
        ]
      ),
      JSONAPI::Request::QueryParamCollection::QueryParam.new('leBron', 'james'),
      JSONAPI::Request::QueryParamCollection::PageParam.new(3, 25),
      JSONAPI::Request::QueryParamCollection::SortParam.new('alpha'),
      JSONAPI::Request::QueryParamCollection::FilterParam.new('special')
    ]

  it_behaves_like 'collection-like classes' do
    
    # rack::request.params:
    # {
    #   "include"=>"author, comments.author",
    #   "fields"=>{"articles"=>"title,body,author", "people"=>"name"},
    #   "leBron"=>"james",
    #   "page"=>{"offset"=>"3", "limit"=>"25"},
    #   "sort"=>"alpha",
    #   "filter"=>"special",
    # }
    
    let(:item_class) { JSONAPI::Request::QueryParamCollection::QueryParam }
    let(:c_size) { 8 }
    let(:keys) { %i[include|author include|comments.likes fields[articles] fields[people] lebron page sort filter] }
    let(:ex_item_key) { :'include|author' }
    let(:ex_item) { JSONAPI::Request::QueryParamCollection::IncludeParam.new('author') }
    
    let(:to_string) do
      "include=author,comments.likes&fields[articles]=title,body,author&fields[people]=name&leBron=james&page[offset]=3&page[limit]=25&sort=alpha&filter=special"
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
      
      expect(only_includes(fields, JSONAPI::Request::QueryParamCollection::FieldsParam)).to eq true
      expect(only_includes(filters, JSONAPI::Request::QueryParamCollection::Filter)).to eq true
      expect(only_includes(includes, JSONAPI::Request::QueryParamCollection::Include)).to eq true
      expect(only_includes(pages, JSONAPI::Request::QueryParamCollection::Page)).to eq true
      expect(only_includes(sorts, JSONAPI::Request::QueryParamCollection::Sort)).to eq true

    end
  end
end
