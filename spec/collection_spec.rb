# frozen_string_literal: true

require 'rack/jsonapi/collection'
require 'rack/jsonapi/item'

describe JSONAPI::Collection do
  
  before do
    obj_arr = [
      { name: 'include', value: 'author,comments,likes' },
      { name: 'lebron', value: 'james' },
      { name: 'charles', value: 'barkley' },
      { name: 'michael', value: 'jordan,jackson' },
      { name: 'kobe', value: 'bryant' }
    ]

    @item_arr = obj_arr.map { |i| JSONAPI::Item.new(i) }
  end

  # Indicates how to get the hash for #add method
  let(:name) { proc { |obj| obj.name } }

  # Our main collection to test
  let(:c) { JSONAPI::Collection.new(@item_arr, &name) }

  # empty collection
  let(:ec) { JSONAPI::Collection.new }
  
  describe '#initialize' do

    it 'should be empty if given no arguments' do
      expect(ec.empty?).to eq true
    end

    it 'should not be empty if given an argument' do
      expect(c.empty?).to eq false
    end
  end

  describe 'empty?' do
    it 'should return true for a collection that was initialized without parameters' do
      expect(ec.empty?).to be true
    end
  end

  describe '#include?' do

    it 'should state whether a given Item is in Collection' do
      expect(c.include?(:include)).to be true
      expect(c.include?(:test)).to be false
    end

    it 'should be case insensitive for checking the name' do
      expect(ec.include?('include')).to be false
      expect(ec.include?(:include)).to be false
      expect(ec.include?('InClUde')).to be false
      item = JSONAPI::Item.new({ name: 'include', value: 'all' })
      ec.add(item, &name)
      expect(ec.include?('include')).to be true
      expect(ec.include?(:include)).to be true
      expect(ec.include?('InClUde')).to be true
    end
  end

  describe '#insert' do
    it 'should raise an error if the input name is already in use' do
      expect(c.collection.include?(:include)).to be true
      expect { c.insert(:include, 'new_include') }.to raise_error 'Item already included. Remove existing item first.'
    end
  end
  
  describe '#add' do

    it 'should make #empty? return false' do
      expect(ec.empty?).to be true
      item = JSONAPI::Item.new({ name: 'test', value: 'ing' })
      ec.add(item, &name)
      expect(ec.empty?).to be false
    end

    it 'should add items to the collection' do
      expect(ec.empty?).to be true
      item = JSONAPI::Item.new({ name: 'test', value: 'ing' })
      ec.add(item, &name)
      expect(ec.collection.include?(:test)).to be true
    end
  end

  describe '#each' do

    context 'collection should respond to enumerable methods' do
      
      it 'should respond to #first' do
        expect(c.respond_to?(:first)).to eq true
      end

      it 'should respond to #filter' do
        expect(c.respond_to?(:filter)).to eq true
      end

      it 'should return an Enumerator when no block is passed' do
        expect(c.each.class).to eq Enumerator
      end

      it 'should be iterating over Item objects' do
        checker = true
        c.each do |item| 
          cur_class = item.class
          checker = ((cur_class == JSONAPI::Item) && checker)
        end
        expect(checker).to eq true
      end
    end
  end

  describe '#remove' do
    it 'should return nil if the key is not in the collection' do
      expect(ec.include?('include')).to be false
      expect(ec.remove('include')).to eq nil
    end

    it 'should remove items from the collection' do
      expect(c.include?('include')).to be true
      item = c.remove('include')
      expect(c.include?('include')).to be false
      expect(item.name).to eq 'include'
      expect(item.class).to eq JSONAPI::Item
    end
  end

  describe '#get' do
    
    it 'should return nil if the collection does not contain the item' do
      expect(ec.get('test')).to eq nil
    end
    
    it 'should return the appropriate item' do
      item = c.get(:include)
      expect(item.class).to eq JSONAPI::Item
      expect(item.name).to eq 'include'
    end

    it 'should be case insensitive and work for symbol or string' do
      item = JSONAPI::Item.new({ name: 'test', value: 'ing' })
      ec.add(item, &name)
      expect(ec.get('test').value).to eq 'ing'
      expect(ec.get(:test).value).to eq 'ing'
      expect(ec.get('TeSt').value).to eq 'ing'
    end
  end

  describe '#keys' do
    it 'should return a list of the names of all the Item objects stored in Collection as lower case symbols' do
      expect(c.keys).to eq %i[include lebron charles michael kobe]
    end
  end

  describe '#size' do
    it 'should return the number of items in the collection' do
      expect(c.size).to eq 5
    end
  end

  describe '#to_s' do

    to_string = 
      '{ ' \
      "include => { name => 'include', value => 'author,comments,likes' }, " \
      "lebron => { name => 'lebron', value => 'james' }, " \
      "charles => { name => 'charles', value => 'barkley' }, " \
      "michael => { name => 'michael', value => 'jordan,jackson' }, " \
      "kobe => { name => 'kobe', value => 'bryant' }" \
      ' }'

    it "should return an array of name/vals hashes as a string representing Collection's contents" do
      expect(c.to_s).to eq to_string
    end
  end

  describe '#to_hash_key' do
    it 'should be private' do
      k1 = 'KEY'
      expect { c.to_hash_key(k1) }.to raise_error NoMethodError
    end
  end
end
