# frozen_string_literal: true

class ItemThatRaisesError

  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

shared_examples 'collection-like classes' do

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
      expect(c.empty?).to be false
      expect(ec.empty?).to be true
    end
  end

  describe '#include?' do

    it 'should state whether a given Item is in Collection' do
      expect(c.include?(ex_item_key)).to be true
      expect(c.include?('not_ex_item_key')).to be false
    end

    it 'should be case sensitive for checking the name' do
      expect(ec.include?(ex_item_key.to_s)).to be false
      expect(ec.include?(ex_item_key.to_sym)).to be false
      expect(ec.include?(ex_item_key.upcase)).to be false
      ec.add(ex_item, &:name)
      expect(ec.include?(ex_item_key.to_s)).to be true
      expect(ec.include?(ex_item_key.to_sym)).to be true
      expect(ec.include?(ex_item_key.upcase)).to be false
    end
  end

  describe '#add' do

    it 'should make #empty? return false' do
      expect(ec.empty?).to be true
      ec.add(ex_item, &:name)
      expect(ec.empty?).to be false
    end

    it 'should add items to the collection' do
      expect(ec.empty?).to be true
      ec.add(ex_item, &:name)
      expect(ec.include?(ex_item_key)).to be true
    end

    it 'should raise if adding an item different than specified type' do
      bad_item = ItemThatRaisesError.new('bad_item')
      error_msg = "Cannot add an item that is not #{item_class}"
      expect { ec.add(bad_item, &:name) }.to raise_error error_msg
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
          checker = ((cur_class == item.class) && checker)
        end
        expect(checker).to eq true
      end
    end
  end

  describe '#remove' do
    it 'should return nil if the key is not in the collection' do
      expect(ec.include?('te_st')).to be false
      expect(ec.remove('te_st')).to eq nil
    end

    it 'should remove items from the collection' do
      expect(c.include?(ex_item_key)).to be true
      item = c.remove(ex_item_key)
      expect(c.include?(ex_item_key)).to be false
      expect(item.is_a?(item_class)).to be true
    end
  end

  describe '#get and #[]' do
    
    it 'should return nil if the collection does not contain the item' do
      expect(ec.get('te_st')).to eq nil
      expect(ec['te_st']).to eq nil
    end
    
    it 'should return the appropriate item' do
      item = c.get(ex_item_key)
      expect(item.is_a?(item_class)).to be true
      item = c[ex_item_key]
      expect(item.is_a?(item_class)).to be true
    end

    it 'should be case sensitive but work for both symbol or string' do
      ec.add(ex_item, &:name)
      item = ec.get(ex_item_key)
      expect(ec.get(ex_item_key.to_s)).to eq item
      item = ec[ex_item_key]
      expect(ec[ex_item_key.to_s]).to eq item
    end
  end

  describe '#set and #[]=' do

    it 'should create a key if it does not exist' do
      expect(ec.get(ex_item_key)).to be nil
      ec.set(ex_item_key, ex_item)
      expect(ec.get(ex_item_key)).to eq ex_item
      
      ec.remove(ex_item_key)
      expect(ec.get(ex_item_key)).to be nil
      ec[ex_item_key] = ex_item
      expect(ec.get(ex_item_key)).to eq ex_item
    end

    it 'should overwrite the value of a key if the key exists already ' do
      ec.set(ex_item_key, ex_item)
      new_ex_item = ex_item.clone
      ec.set(ex_item_key, new_ex_item)
      expect(ex_item.object_id).not_to eq new_ex_item.object_id
      expect(ec.get(ex_item_key)).to eq new_ex_item
      
      ec[ex_item_key] = ex_item
      new_ex_item = ex_item.clone
      ec[ex_item_key] = new_ex_item
      expect(ex_item.object_id).not_to eq new_ex_item.object_id
      expect(ec.get(ex_item_key)).to eq new_ex_item
    end
  end



  describe '#keys' do
    it 'should return a list of the names of all the Item objects stored in Collection as lower case symbols' do
      expect(c.keys).to eq keys
    end
  end

  describe '#size' do
    it 'should return the number of items in the collection' do
      expect(c.size).to eq c_size
    end
  end

  describe '#to_s' do
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
