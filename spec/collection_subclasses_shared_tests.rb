# frozen_string_literal: true

shared_examples 'collection like classes' do

  def init_item(name, value, item_class)
    if item_class == JSONAPI::Item
      item_class.new({ name: name, value: value })
    else
      item_class.new(name, value)
    end
  end

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
      expect(c.include?(:te_st)).to be false
    end

    it 'should be case insensitive for checking the name' do
      expect(ec.include?(:te_st)).to be false
      expect(ec.include?('te_st')).to be false
      expect(ec.include?('tE_St')).to be false
      item = init_item('te_st', 'ing', item_class)
      ec.add(item, &:name)
      expect(ec.include?(:te_st)).to be true
      expect(ec.include?('te_st')).to be true
      expect(ec.include?('tE_St')).to be true
    end
  end

  describe '#add' do

    it 'should make #empty? return false' do
      expect(ec.empty?).to be true
      item = init_item('te_st', 'ing', item_class)
      ec.add(item, &:name)
      expect(ec.empty?).to be false
    end

    it 'should add items to the collection' do
      expect(ec.empty?).to be true
      item = init_item('te_st', 'ing', item_class)
      ec.add(item, &:name)
      expect(ec.include?(:te_st)).to be true
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
      expect(item.name.downcase).to eq ex_item_key.to_s
      expect(item.is_a?(item_class)).to be true
    end
  end

  describe '#get' do
    
    it 'should return nil if the collection does not contain the item' do
      expect(ec.get('te_st')).to eq nil
    end
    
    it 'should return the appropriate item' do
      item = c.get(ex_item_key)
      expect(item.is_a?(item_class)).to be true
      expect(item.name.downcase).to eq ex_item_key.to_s
    end

    it 'should be case insensitive and work for symbol or string' do
      item = init_item('te_st', 'ing', item_class)
      ec.add(item, &:name)
      item = ec.get('te_st')
      expect(ec.get(:te_st)).to eq item
      expect(ec.get('Te_St')).to eq item
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
