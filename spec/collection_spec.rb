# frozen_string_literal: true

require 'rack/jsonapi/collection'

describe JSONAPI::Collection do
  
  let(:arr_of_objs) do
    
  end

  before do
    # arr_of_objs = [
    #   { key: 'include', val: 'authors,comments,likes' },
    #   { key: 'lebron', val: 'james' },
    #   { key: 'charles', val: 'barkley' },
    #   { key: 'michael', val: 'jordan,jackson' },
    #   { key: 'kobe', val: 'bryant' }
    # ]

    # @collection = JSONAPI::Collection.new
    # arr_of_objs.each do |obj|
    #   cur_item = JSONAPI::Collection::Item.new(obj)
    #   @collection.add(cur_item) { |item| item[:key] }
    # end
    
  end

  let(:c) { @collection }

  let(:key) { proc { |obj| obj.key } }
  
  describe '#initialize' do
    # let(:temp) { JSONAPI::Collection.new }

    it 'should work' do
      
      # Item 1
      obj = { 'articles' => 'title,body,author', 'people' => 'name' }
      i1 = JSONAPI::Collection::Item.new(obj)
      puts ' '
      pp i1.instance_variables
      pp JSONAPI::Collection::Item.instance_methods(false) 
      pp i1.articles
      puts ' '
      
      # Item 2
      obj2 = { 'offset' => '1', 'limit' => ' 1' }
      i2 = JSONAPI::Collection::Item.new(obj2)
      pp i2.instance_variables
      pp JSONAPI::Collection::Item.instance_methods(false) 
      pp i2.limit
      puts ' '
      
      # Item 1 calling a item 2 method
      pp i1.limit

      # Changing value of offset
      i2.offset = 2
      pp i2.offset
      i2.coll

    end

    # it 'should be empty if given no arguments' do
    #   expect(temp.empty?).to eq true
    # end
  end

  # describe '#insert' do
  #   it 'should raise an error if the input key is already in use' do
  #     expect(c.collection.include?(:test)).to be false
  #     c.add(JSONAPI::Collection::Item.new(:test, 'ing'), &:key)
  #     expect(c.collection.include?(:test)).to be true
  #     expect { c.insert(:test, 'ing') }.to raise_error 'Item already included. Remove existing item first.'
  #   end
  # end
  
  # describe '#add' do
  #   let(:temp) { JSONAPI::Collection.new }

  #   it 'should make #empty? return false' do
  #     expect(temp.empty?).to be true
  #     temp.add(JSONAPI::Collection::Item.new({test: 'ing'}), &:key)
  #     expect(temp.empty?).to be false
  #   end

  #   it 'should add items to the collection' do
  #     expect(temp.empty?).to be true
  #     temp.add(JSONAPI::Collection::Item.new('test', 'ing'), &:key)
  #     expect(temp.collection.include?(:test)).to be true
  #   end
  # end

  # describe '#each' do

  #   context 'c should respond to enumerable methods' do
      
  #     it 'should respond to #first' do
  #       expect(c.respond_to?(:first)).to eq true
  #     end

  #     it 'should respond to #filter' do
  #       expect(c.respond_to?(:filter)).to eq true
  #     end

  #     it 'should return an Enumerator when no block is passed' do
  #       expect(c.each.class).to eq Enumerator
  #     end

  #     it 'should be iterating over Item objects' do
  #       checker = true
  #       c.each do |item| 
  #         cur_class = item.class
  #         pp cur_class
  #         checker = ((cur_class == JSONAPI::Collection::Item) && checker)
  #       end
  #       expect(checker).to eq true
  #     end
  #   end
  # end

  # # #add

  # # #<<

  # describe '#include?' do
  #   let(:c) { JSONAPI::Collection.new(arr_of_objs) }

  #   it 'should state whether a given Item is in Collection' do
  #     expect(c.include?(:michael)).to be true
  #     expect(c.include?(:joe)).to be false
  #   end

  #   it 'should be case insensitive for checking the key' do
  #     expect(c.include?('include')).to be true
  #     expect(c.include?(:include)).to be true
  #     expect(c.include?('InClUde')).to be true
  #     c.remove(:include)
  #     expect(c.include?('include')).to be false
  #     expect(c.include?(:include)).to be false
  #     expect(c.include?('InClUde')).to be false
  #   end
  # end

  # # #remove

  # describe '#get' do
  #   let(:c) { JSONAPI::Collection.new(arr_of_objs) }
    
  #   it 'should return vals the appropriate item object' do
  #     item = c.get(:include)
  #     expect(item.class).to eq JSONAPI::Collection::Item
  #     expect(item.key.downcase).to eq 'include'
  #   end

  #   it 'should be case insensitive and work for symbol or string for "key"' do
  #     expect(c.get(:joe)).to be nil
  #     c.add(JSONAPI::Collection::Item.new(:joe, ['schmo']))
  #     expect(c.get(:joe).vals).to eq ['schmo']
  #     expect(c.get('joe').vals).to eq ['schmo']
  #     expect(c.get('jOE').vals).to eq ['schmo']
  #   end
  # end

  # # #update

  # describe '#keys' do
  #   let(:c) { JSONAPI::Collection.new(arr_of_objs) }

  #   it 'should return a list of the names of all the Item objects stored in Collection as lower case symbols' do
  #     expect(c.keys).to eq %i[include lebron charles michael kobe]
  #   end
  # end

  # # #to_hash_key

  # describe '#to_s' do
  #   let(:c) { JSONAPI::Collection.new(arr_of_objs) }
  #   to_string = 
  #     '{' \
  #       ":include => [\"authors\", \"comments\", \"likes\"], " \
  #       ":lebron => [\"james\"], " \
  #       ":charles => [\"barkley\"], " \
  #       ":michael => [\"jordan\", \"jackson\"], " \
  #       ":kobe => [\"bryant\"]" \
  #     '}'

  #   it "should return an array of key/vals hashes as a string representing Collection' contents" do
  #     expect(c.to_s).to eq to_string
  #   end
  # end

  # describe JSONAPI::Collection::Item do
  #   let(:item) { JSONAPI::Collection::Item.new('joe', ['schmoe', 'go']) }
    
  #   describe '#to_s' do
  #     it 'should return a Item key and vals as "key => vals"' do
  #       expect(item.to_s).to eq "joe => [\"schmoe\", \"go\"]"
  #     end
  #   end

  #   describe '#add' do
  #     it 'should be able to delete the value given the value to look for' do 
  #       expect(item.remove('schmoe')).to eq 'schmoe'
  #     end

  #     it 'should be able to delete the value given the index to look for' do
  #       expect(item.remove(1)).to eq 'go'
  #     end
  #   end
  # end
end
