# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/name_value_pair_collection'
require 'rack/jsonapi/request/query_param_collection'

require 'rack/jsonapi/request/query_param_collection/include_param'

require 'rack/jsonapi/request/query_param_collection/filter_param'
require 'rack/jsonapi/request/query_param_collection/filter_param/filter'

require 'rack/jsonapi/request/query_param_collection/page_param'
require 'rack/jsonapi/request/query_param_collection/sort_param'

require 'rack/jsonapi/request/query_param_collection/fields_param'
require 'rack/jsonapi/request/query_param_collection/fields_param/fieldset'

require 'rack/jsonapi/field'

require 'shared_examples/name_value_pair_collections'

describe JSONAPI::Request::QueryParamCollection do

  item_arr = 
    [
      JSONAPI::Request::QueryParamCollection::IncludeParam.new(['author', 'comments.likes']),
      JSONAPI::Request::QueryParamCollection::FieldsParam.new(
        [
          JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new(
            'articles', 
            [
              JSONAPI::Field.new('title'), 
              JSONAPI::Field.new('body'),
              JSONAPI::Field.new('author')
            ]
          ),
          JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new(
            'people', 
            [
              JSONAPI::Field.new('name')
            ]
          )
        ]
      ),
      JSONAPI::Request::QueryParamCollection::QueryParam.new('leBron', 'james'),
      JSONAPI::Request::QueryParamCollection::PageParam.new(offset: 3, limit: 25),
      JSONAPI::Request::QueryParamCollection::SortParam.new(['alpha']),
      JSONAPI::Request::QueryParamCollection::FilterParam.new(
        [JSONAPI::Request::QueryParamCollection::FilterParam::Filter.new('res_name', 'special')]
      )
    ]
    
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
  let(:c_size) { 6 }
  let(:keys) { %i[includes fields leBron page sorts filters] }
  let(:ex_item_key) { :leBron }
  let(:ex_item) { JSONAPI::Request::QueryParamCollection::QueryParam.new('leBron', 'james') }

  let(:to_string) do
    'include=author,comments.likes&fields[articles]=title,body,author&fields[people]=name&' \
    'leBron=james&page[offset]=3&page[limit]=25&sort=alpha&filter[res_name]=special'
  end

  let(:c) { JSONAPI::Request::QueryParamCollection.new(item_arr, &:name) }
  let(:ec) { JSONAPI::Request::QueryParamCollection.new }

  it_behaves_like 'name value pair collections' do
  end

  describe '#method_missing' do

    let(:pc) { JSONAPI::Request::QueryParamCollection.new(item_arr, &:name) }
    
    it 'should allow you to have dynamic methods for special params' do
      fields = pc.fields
      filters = pc.filters
      includes = pc.includes
      pages = pc.page
      sorts = pc.sorts

      expect(fields.class).to eq JSONAPI::Request::QueryParamCollection::FieldsParam
      expect(filters.class).to eq JSONAPI::Request::QueryParamCollection::FilterParam
      expect(includes.class).to eq JSONAPI::Request::QueryParamCollection::IncludeParam
      expect(pages.class).to eq JSONAPI::Request::QueryParamCollection::PageParam
      expect(sorts.class).to eq JSONAPI::Request::QueryParamCollection::SortParam
    end
  end
end
