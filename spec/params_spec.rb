# frozen_string_literal: true

require 'rack/jsonapi/pairs'

describe JSONAPI::Pairs do
  
  let(:test_input) do
    [
      ['include', 'authors,comments,likes'],
      ['lebron', 'james'],
      ['charles', 'barkley'],
      ['michael', 'jordan,jackson'],
      ['kobe', 'bryant']
    ]
  end
  
  describe '#each' do
    let(:pairs) { JSONAPI::Pairs.new(test_input) }

    context 'pairs should respond to enumerable methods' do
      
      it 'should respond to #first' do
        puts pairs.to_s
        expect(pairs.respond_to?(:first)).to eq true
      end

      it 'should respond to #filter' do
        expect(pairs.respond_to?(:filter)).to eq true
      end

      it 'should return an Enumerator when no block is passed' do
        expect(pairs.each.class).to eq Enumerator
      end

      it 'should be iterating over Pair objects' do
        checker = true
        pairs.each do |pair| 
          checker = ((pair.class == JSONAPI::Pairs::Pair) && checker)
        end
        expect(checker).to eq true
      end

    end
  end

  # #add

  # #<<

  describe '#include?' do
    let(:pairs) { JSONAPI::Pairs.new(test_input) }

    it 'should state whether a given Pair is in Pairs' do
      expect(pairs.include?(:michael)).to be true
      expect(pairs.include?(:joe)).to be false
    end

    it 'should be case insensitive for checking the key' do
      expect(pairs.include?('include')).to be true
      expect(pairs.include?(:include)).to be true
      expect(pairs.include?('InClUde')).to be true
      pairs.remove(:include)
      expect(pairs.include?('include')).to be false
      expect(pairs.include?(:include)).to be false
      expect(pairs.include?('InClUde')).to be false
    end
  end

  # #remove

  describe '#get' do
    let(:pairs) { JSONAPI::Pairs.new(test_input) }
    
    it 'should return vals the appropriate pair object' do
      pair = pairs.get(:include)
      expect(pair.class).to eq JSONAPI::Pairs::Pair
      expect(pair.key.downcase).to eq 'include'
    end

    it 'should be case insensitive and work for symbol or string for "key"' do
      expect(pairs.get(:joe)).to be nil
      pairs.add(JSONAPI::Pairs::Pair.new(:joe, ['schmo']))
      expect(pairs.get(:joe).vals).to eq ['schmo']
      expect(pairs.get('joe').vals).to eq ['schmo']
      expect(pairs.get('jOE').vals).to eq ['schmo']
    end
  end

  # #update

  describe '#keys' do
    let(:pairs) { JSONAPI::Pairs.new(test_input) }

    it 'should return a list of the names of all the Pair objects stored in Pairs as lower case symbols' do
      expect(pairs.keys).to eq %i[include lebron charles michael kobe]
    end
  end

  # #to_hash_key

  describe '#to_s' do
    let(:pairs) { JSONAPI::Pairs.new(test_input) }
    to_string = 
      '{' \
        ":include => [\"authors\", \"comments\", \"likes\"], " \
        ":lebron => [\"james\"], " \
        ":charles => [\"barkley\"], " \
        ":michael => [\"jordan\", \"jackson\"], " \
        ":kobe => [\"bryant\"]" \
      '}'

    it "should return an array of key/vals hashes as a string representing Pairs' contents" do
      expect(pairs.to_s).to eq to_string
    end
  end

  describe JSONAPI::Pairs::Pair do
    let(:pair) { JSONAPI::Pairs::Pair.new('joe', ['schmoe', 'go']) }
    
    describe '#to_s' do
      it 'should return a Pair key and vals as "key => vals"' do
        expect(pair.to_s).to eq "joe => [\"schmoe\", \"go\"]"
      end
    end

    describe '#add' do
      it 'should be able to delete the value given the value to look for' do 
        expect(pair.remove('schmoe')).to eq 'schmoe'
      end

      it 'should be able to delete the value given the index to look for' do
        expect(pair.remove(1)).to eq 'go'
      end
    end
  end
end
