# frozen_string_literal: true

shared_examples 'collection like classes' do
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
      expect(c.include?(ex_item_key)).to be true
      expect(c.include?(:test)).to be false
    end

    it 'should be case insensitive for checking the name' do
      expect(ec.include?(:test)).to be false
      expect(ec.include?('test')).to be false
      expect(ec.include?('tESt')).to be false
      item = item_class.new('test', 'ing')
      ec.add(item, &:name)
      expect(ec.include?(:test)).to be true
      expect(ec.include?('test')).to be true
      expect(ec.include?('tESt')).to be true
    end
  end

  describe '#add' do

    it 'should make #empty? return false' do
      expect(ec.empty?).to be true
      item = item_class.new('test', 'ing')
      ec.add(item, &:name)
      expect(ec.empty?).to be false
    end

    it 'should add items to the collection' do
      expect(ec.empty?).to be true
      item = item_class.new('test', 'ing')
      ec.add(item, &:name)
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
          checker = ((cur_class == item.class) && checker)
        end
        expect(checker).to eq true
      end
    end
  end

  describe '#remove' do
    it 'should return nil if the key is not in the collection' do
      expect(ec.include?('test')).to be false
      expect(ec.remove('test')).to eq nil
    end

    it 'should remove items from the collection' do
      expect(c.include?(ex_item_key)).to be true
      item = c.remove(ex_item_key)
      expect(c.include?(ex_item_key)).to be false
      expect(item.name.downcase).to eq ex_item_key.to_s
      expect(item.is_a?(item_class)).to be true
    end
  end

  describe '#get' do
    
    it 'should return nil if the collection does not contain the item' do
      expect(ec.get('test')).to eq nil
    end
    
    it 'should return the appropriate item' do
      item = c.get(ex_item_key)
      expect(item.is_a?(item_class)).to be true
      expect(item.name.downcase).to eq ex_item_key.to_s
    end

    it 'should be case insensitive and work for symbol or string' do
      item = item_class.new('test', 'ing')
      ec.add(item, &:name)
      item = ec.get('test')
      expect(ec.get(:test)).to eq item
      expect(ec.get('TeSt')).to eq item
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
