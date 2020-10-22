# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/collection/header_collection'
require 'rack/jsonapi/item'
require 'rack/jsonapi/header'

describe JSONAPI::Collection::HeaderCollection do

  before do
    obj_arr = [
      { name: 'Content-Type', value: 'application/vnd.api+json' },
      { name: 'Accept', value: 'application/vnd.api+json, text/plain, text/html ; level=1 ; q=0.5, text/x-div; q=0.8, text/x-c, */*' },
      { name: 'Host', value: 'localhost:9292' },
      { name: 'Connection', value: 'keep-alive' },
      { name: 'WWW-Authenticate', value: 'Basic realm="Access to the staging site", charset="UTF-8"' }
    ]

    @param_arr = obj_arr.map { |obj| JSONAPI::Header.new(obj[:name], obj[:value]) }
  end

  # Our main collection to test
  let(:hc) { JSONAPI::Collection::HeaderCollection.new(@param_arr) }

  # empty collection
  let(:ehc) { JSONAPI::Collection::HeaderCollection.new }

  describe '#initialize' do
    it 'should be empty if given no arguments' do
      expect(ehc.empty?).to eq true
    end

    it 'should not be empty if given an argument' do
      expect(hc.empty?).to eq false
    end
  end

  describe 'empty?' do
    it 'should return true for a collection that was initialized without parameters' do
      expect(ehc.empty?).to be true
    end
  end

  describe '#include?' do
    it 'should state whether a given Item is in Collection' do
      expect(hc.include?(:host)).to be true
      expect(hc.include?(:test)).to be false
    end

    it 'should be case insensitive for checking the name' do
      expect(ehc.include?('new_header')).to be false
      expect(ehc.include?(:new_header)).to be false
      expect(ehc.include?('nEw_HEadEr')).to be false
      header = JSONAPI::Header.new('new_header', 'new_val')
      ehc.add(header)
      expect(ehc.include?('new_header')).to be true
      expect(ehc.include?(:new_header)).to be true
      expect(ehc.include?('nEw_HEadEr')).to be true
    end
  end

  describe '#insert' do
    it 'should raise an error if the input name is already in use' do
      expect(hc.collection.include?(:host)).to be true
      expect { hc.insert(:host, 'new_value') }.to raise_error 'Item already included. Remove existing item first.'
    end
  end
  
  describe '#add' do
    it 'should make #empty? return false' do
      expect(ehc.empty?).to be true
      item = JSONAPI::Header.new('test', 'ing')
      ehc.add(item)
      expect(ehc.empty?).to be false
    end

    it 'should add items to the collection' do
      expect(ehc.empty?).to be true
      header = JSONAPI::Header.new('test', 'ing')
      ehc.add(header)
      expect(ehc.collection.include?(:test)).to be true
    end
  end

  describe '#each' do

    context 'header collection should respond to enumerable methods' do
      
      it 'should respond to #first' do
        expect(hc.respond_to?(:first)).to eq true
      end

      it 'should respond to #filter' do
        expect(hc.respond_to?(:filter)).to eq true
      end

      it 'should return an Enumerator when no block is passed' do
        expect(hc.each.class).to eq Enumerator
      end

      it 'should be iterating over Item objects' do
        checker = true
        hc.each do |header| 
          cur_class = header.class
          checker = ((cur_class == JSONAPI::Header) && checker)
        end
        expect(checker).to eq true
      end
    end
  end

  describe '#remove' do
    it 'should return nil if the key is not in the collection' do
      expect(ehc.include?('host')).to be false
      expect(ehc.remove('host')).to eq nil
    end

    it 'should remove items from the collection' do
      expect(hc.include?('host')).to be true
      header = hc.remove('host')
      expect(hc.include?('host')).to be false
      expect(header.name).to eq 'Host'
      expect(header.class).to eq JSONAPI::Header
    end
  end

  describe '#get' do
    
    it 'should return nil if the collection does not contain the header' do
      expect(ehc.get('test')).to eq nil
    end
    
    it 'should return the appropriate header' do
      header = hc.get(:host)
      expect(header.class).to eq JSONAPI::Header
      expect(header.name).to eq 'Host'
    end

    it 'should be case insensitive and work for symbol or string' do
      header = JSONAPI::Header.new('test', 'ing')
      ehc.add(header)
      expect(ehc.get('test').value).to eq 'ing'
      expect(ehc.get(:test).value).to eq 'ing'
      expect(ehc.get('TeSt').value).to eq 'ing'
    end
  end

  describe '#keys' do
    it 'should return a list of the names of all the Item objects stored in Collection as lower case symbols' do
      expect(hc.keys).to eq %i[content-type accept host connection www-authenticate]
    end
  end

  describe '#size' do
    it 'should return the number of items in the collection' do
      expect(hc.size).to eq 5
    end
  end

  describe '#to_s' do
  
    to_string = 
      '{ ' \
      "{ 'Content-Type' => 'application/vnd.api+json' }, " \
      "{ 'Accept' => 'application/vnd.api+json, text/plain, text/html ; level=1 ; q=0.5, text/x-div; q=0.8, text/x-c, */*' }, " \
      "{ 'Host' => 'localhost:9292' }, " \
      "{ 'Connection' => 'keep-alive' }, " \
      "{ 'WWW-Authenticate' => 'Basic realm=\"Access to the staging site\", charset=\"UTF-8\"' }" \
      ' }'

    it "should return an array of name/vals hashes as a string representing Collection's contents" do
      expect(hc.to_s).to eq to_string
    end
  end
end
