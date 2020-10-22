# frozen_string_literal: true


require 'rack/jsonapi/collection'
require 'rack/jsonapi/collection/param_collection'

require 'rack/jsonapi/item'
require 'rack/jsonapi/item/query_param'
require 'rack/jsonapi/item/query_param/field'
require 'rack/jsonapi/item/query_param/filter'
require 'rack/jsonapi/item/query_param/include'
require 'rack/jsonapi/item/query_param/page'
require 'rack/jsonapi/item/query_param/sort'

require 'rack/jsonapi/document/data/resource/field'

describe JSONAPI::Collection::ParamCollection do
  
  before do
    # rack::request.params:
    # {
    #   "include"=>"author, comments.author",
    #   "fields"=>{"articles"=>"title,body,author", "people"=>"name"},
    #   "josh_ua"=>"demoss",
    #   "page"=>{"offset"=>"1", "limit"=>"1"},
    #   "sort"=>"alpha",
    #   "filter"=>"special",
    # }

    @param_arr = 
      [
        JSONAPI::Item::QueryParam::Include.new('author,comments.likes'),
        JSONAPI::Item::QueryParam::Field.new(
          'articles', 
          [
            JSONAPI::Document::Data::Resource::Field.new('title', nil), 
            JSONAPI::Document::Data::Resource::Field.new('body', nil)
          ]
        ),
        JSONAPI::Item::QueryParam::Field.new(
          'people', 
          [
            JSONAPI::Document::Data::Resource::Field.new('name', nil)
          ]
        ),
        JSONAPI::Item::QueryParam.new('leBron', 'james'),
        JSONAPI::Item::QueryParam::Page.new(3, 25),
        JSONAPI::Item::QueryParam::Sort.new('alpha'),
        JSONAPI::Item::QueryParam::Filter.new('special')
      ]
  end

  # Our main collection to test
  let(:pc) { JSONAPI::Collection::ParamCollection.new(@param_arr) }

  # empty collection
  let(:epc) { JSONAPI::Collection::ParamCollection.new }
  
  describe '#initialize' do
    it 'should be empty if given no arguments' do
      expect(epc.empty?).to eq true
    end

    it 'should not be empty if given an argument' do
      expect(pc.empty?).to eq false
    end
  end

  describe 'empty?' do
    it 'should return true for a collection that was initialized without parameters' do
      expect(epc.empty?).to be true
    end
  end

  describe '#include?' do
    it 'should state whether a given Item is in Collection' do
      expect(pc.include?(:include)).to be true
      expect(pc.include?(:test)).to be false
    end

    it 'should be case insensitive for checking the name' do
      expect(epc.include?('include')).to be false
      expect(epc.include?(:include)).to be false
      expect(epc.include?('InClUde')).to be false
      query_param = JSONAPI::Item::QueryParam::Include.new('all')
      epc.add(query_param)
      expect(epc.include?('include')).to be true
      expect(epc.include?(:include)).to be true
      expect(epc.include?('InClUde')).to be true
    end
  end

  describe '#add' do
    it 'should make #empty? return false' do
      expect(epc.empty?).to be true
      item = JSONAPI::Item::QueryParam.new('test', 'ing')
      epc.add(item)
      expect(epc.empty?).to be false
    end

    it 'should add items to the collection' do
      expect(epc.empty?).to be true
      query_param = JSONAPI::Item::QueryParam.new('test', 'ing')
      epc.add(query_param)
      expect(epc.collection.include?(:test)).to be true
    end
  end

  describe '#each' do

    context 'query_param collection should respond to enumerable methods' do
      
      it 'should respond to #first' do
        expect(pc.respond_to?(:first)).to eq true
      end

      it 'should respond to #filter' do
        expect(pc.respond_to?(:filter)).to eq true
      end

      it 'should return an Enumerator when no block is passed' do
        expect(pc.each.class).to eq Enumerator
      end

      it 'should be iterating over Item objects' do
        checker = true
        pc.each do |query_param| 
          checker = ((query_param.is_a? JSONAPI::Item::QueryParam) && checker)
        end
        expect(checker).to eq true
      end
    end
  end

  describe '#remove' do
    it 'should return nil if the key is not in the collection' do
      expect(epc.include?('include')).to be false
      expect(epc.remove('include')).to eq nil
    end

    it 'should remove items from the collection' do
      expect(pc.include?('include')).to be true
      query_param = pc.remove('include')
      expect(pc.include?('include')).to be false
      expect(query_param.name).to eq 'include'
      expect(query_param.is_a?(JSONAPI::Item::QueryParam)).to be true
    end
  end

  describe '#get' do
    
    it 'should return nil if the collection does not contain the query_param' do
      expect(epc.get('test')).to eq nil
    end
    
    it 'should return the appropriate query_param' do
      query_param = pc.get(:include)
      expect(query_param.is_a?(JSONAPI::Item::QueryParam)).to be true
      expect(query_param.name).to eq 'include'
    end

    it 'should be case insensitive and work for symbol or string' do
      query_param = JSONAPI::Item::QueryParam.new('test', 'ing')
      epc.add(query_param)
      expect(epc.get('test').value).to eq ['ing']
      expect(epc.get(:test).value).to eq ['ing']
      expect(epc.get('TeSt').value).to eq ['ing']
    end
  end

  describe '#keys' do
    it 'should return a list of the names of all the Item objects stored in Collection as lower case symbols' do
      expect(pc.keys).to eq %i[include fields[articles] fields[people] lebron page sort filter]
    end
  end

  describe '#size' do
    it 'should return the number of items in the collection' do
      expect(pc.size).to eq 7
    end
  end

  describe '#to_s' do
  
    to_string = 
      '{ ' \
        "include => { 'include' => 'author,comments.likes' }, " \
        "fields[articles] => { fields => { 'articles' => 'title,body' } }, " \
        "fields[people] => { fields => { 'people' => 'name' } }, " \
        "lebron => { 'leBron' => 'james' }, " \
        "page => { page => { 'offset' => '3', 'limit' => '25' } }, " \
        "sort => { 'sort' => 'alpha' }, " \
        "filter => { 'filter' => 'special' }" \
      ' }'

    it "should return an array of name/vals hashes as a string representing Collection's contents" do
      expect(pc.to_s).to eq to_string
    end
  end

  describe '#method_missing' do
    
    def only_includes(param_collection, query_param)
      checker = true
      param_collection.each do |p|
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

      expect(fields.class).to eq JSONAPI::Collection::ParamCollection
      expect(filters.class).to eq JSONAPI::Collection::ParamCollection
      expect(includes.class).to eq JSONAPI::Collection::ParamCollection
      expect(pages.class).to eq JSONAPI::Collection::ParamCollection
      expect(sorts.class).to eq JSONAPI::Collection::ParamCollection
      
      expect(only_includes(fields, JSONAPI::Item::QueryParam::Field)).to eq true
      expect(only_includes(filters, JSONAPI::Item::QueryParam::Filter)).to eq true
      expect(only_includes(includes, JSONAPI::Item::QueryParam::Include)).to eq true
      expect(only_includes(pages, JSONAPI::Item::QueryParam::Page)).to eq true
      expect(only_includes(sorts, JSONAPI::Item::QueryParam::Sort)).to eq true

    end
  end
end
