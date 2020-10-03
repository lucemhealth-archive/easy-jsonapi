# frozen_string_literal: true

require 'rack/jsonapi/headers'

describe JSONAPI::Headers do
  
  let(:test_input) do
    [
      ['ACCEPT', 'application/vnd.api+json'],
      ['POSTMAN_TOKEN', '71160056-fbd7-4fb5-8031-914836b880fd'],
      ['HOST', 'localhost:8080'],
      ['CONTENT_TYPE', 'application/vnd.api+json']
    ]
  end
  
  describe '#each' do
    let(:headers) { JSONAPI::Headers.new(test_input) }

    context 'headers should respond to enumerable methods' do
      
      it 'should respond to #first' do
        expect(headers.respond_to?(:first)).to eq true
      end

      it 'should respond to #filter' do
        expect(headers.respond_to?(:filter)).to eq true
      end

      it 'should return an Enumerator when no block is passed' do
        expect(headers.each.class).to eq Enumerator
      end

      it 'should be iterating over Header objects' do
        checker = true
        headers.each do |hdr| 
          checker = ((hdr.class == JSONAPI::Headers::Header) && checker)
        end
        expect(checker).to eq true
      end

    end
  end
 
  # describe '#add' do
  #   let(:headers) { JSONAPI::Headers.new(test_input) }

  #   it 'should add a new header if there is not already one with the same name' do
  #     hdr = JSONAPI::Headers::Header.new(:josh, 'demoss')
  #     expect(headers.get(:josh)).to eq nil
  #     headers.add(hdr)
  #     expect(headers.get(:josh).vals).to eq ['demoss']
  #   end

  #   it 'should add to the header value if there already is one with the same name' do
  #     hdr = JSONAPI::Headers::Header.new(:accept, 'additional_hdr')
  #     expect(headers.get(:accept)).not_to be nil
  #     expect(headers.add(hdr).vals).to eq ['application/vnd.api+json', 'additional_hdr']
  #   end

  #   it 'should be case insensitive and work for symbol or string for "key"' do
  #     hdr = JSONAPI::Headers::Header.new(:josh, 'demoss')
  #     hdr2 = JSONAPI::Headers::Header.new(:josh, 'is')
  #     hdr3 = JSONAPI::Headers::Header.new(:josh, 'cool')
  #     expect(headers.get('josh')).to eq nil
  #     headers.add(hdr)
  #     expect(headers.get('josh').vals).to eq ['demoss']
  #     headers.add(hdr2)
  #     expect(headers.get('josh').vals).to eq ['demoss', 'is']
  #     headers.add('JOSH', 'cool')
  #     expect(headers.get('josh').vals).to eq 'demoss, is, cool'
  #   end
  # end

  # # The method #<< should do similar functionality to add, just has more cases to check.
  # describe '#<<' do
  #   let(:headers) { JSONAPI::Headers.new(test_input) }

  #   it 'should raise ArgumentError if given no arguments or an array where size != 2' do
  #     expect { headers << () }.to raise_error ArgumentError
  #     expect { headers << ['josh', 'is', 'cool'] }.to raise_error ArgumentError
  #   end

  #   it 'should add a new header if there is not already one with the same name' do
  #     expect(headers.get(:josh)).to eq nil
  #     headers << ['josh', 'demoss']
  #     expect(headers.get(:josh).vals).to eq 'demoss'
  #   end

  #   it 'should replace any headers with the same name' do
  #     temp = JSONAPI::Headers.new(test_input)
  #     expect(temp.get('ACCEPT').vals).to eq 'application/vnd.api+json'
  #     temp << ['accept', 'changed']
  #     expect(temp.get('ACCEPT').vals).to eq 'application/vnd.api+json, changed'
  #   end

  #   it 'should be case insensitive and work for symbol or string for "key"' do
  #     expect(headers.get('josh')).to eq nil
  #     headers << ['josh', 'demoss']
  #     expect(headers.get('josh').vals).to eq 'demoss'
  #     headers << [:josh, 'is']
  #     expect(headers.get('josh').vals).to eq 'demoss, is'
  #     headers << ['JOSH', 'cool']
  #     expect(headers.get('josh').vals).to eq 'demoss, is, cool'
  #   end
  # end

  describe '#include?' do
    let(:headers) { JSONAPI::Headers.new(test_input) }

    it 'should state whether a given Header is in Headers' do
      expect(headers.include?(:host)).to be true
      expect(headers.include?(:josh)).to be false
    end

    it 'should be case insensitive for checking the key' do
      temp = JSONAPI::Headers.new(test_input)
      expect(temp.include?('host')).to be true
      expect(temp.include?(:host)).to be true
      expect(temp.include?('HosT')).to be true
      temp.remove(:host)
      expect(temp.include?(:host)).to be false
      expect(temp.include?('host')).to be false
      expect(temp.include?('HosT')).to be false
    end
  end

  # describe '#remove' do
  #   let(:headers) { JSONAPI::Headers.new(test_input) }

  #   it 'should remove a header from headers and return that header class' do
  #     temp = JSONAPI::Headers.new(test_input)
  #     # before the header was removed
  #     expect(temp.include?(:accept)).to eq true
      
  #     deleted = temp.remove(:accept)

  #     # check if the appropriate header was returned
  #     expect(deleted.class).to eq JSONAPI::Headers::Header
  #     expect(deleted.key.downcase).to eq 'accept'
      
  #     # check if the header was removed
  #     expect(temp.include?(:accept)).to eq false
  #   end

  #   it 'should be case insensitive and work for symbol or string for "key"' do
  #     expect(headers.get(:accept)).not_to be nil
  #     expect(headers.get(:host)).not_to be nil
  #     expect(headers.get(:content_type)).not_to be nil

  #     headers.remove('accept')
  #     expect(headers.get(:accept)).to be nil
  #     headers.remove('hOsT')
  #     expect(headers.get(:host)).to be nil
  #     headers.remove(:content_type)
  #     expect(headers.get(:content_type)).to be nil
  #   end
  # end

  describe '#get' do
    let(:headers) { JSONAPI::Headers.new(test_input) }
    
    it 'should return vals the appropriate header object' do
      hdr = headers.get(:accept)
      expect(hdr.class).to eq JSONAPI::Headers::Header
      expect(hdr.key.downcase).to eq 'accept'
    end

    it 'should be case insensitive and work for symbol or string for "key"' do
      temp = JSONAPI::Headers.new(test_input)
      expect(temp.get(:josh)).to be nil
      temp.add(:josh, 'demoss')
      expect(temp.get(:josh).vals).to eq 'demoss'
      expect(temp.get('josh').vals).to eq 'demoss'
      expect(temp.get('JoSH').vals).to eq 'demoss'
    end
  end

  # describe '#set' do
  #   it 'should replace any headers with the same name' do
  #     temp = JSONAPI::Headers.new(test_input)
  #     expect(temp.get('ACCEPT').vals).to eq 'application/vnd.api+json'
  #     temp.add('accept', 'changed')
  #     expect(temp.get('ACCEPT').vals).to eq 'application/vnd.api+json, changed'
  #   end

  #   it "should add a Header if it doesn't exist" do
  #     temp = JSONAPI::Headers.new(test_input)
  #     expect(temp.include?(:josh)).to be false
  #     temp.set(:josh, 'demoss')
  #     expect(temp.include?(:josh)).to be true
  #   end

  #   it 'should be case insensitive and work for symbol or string for "key"' do
  #     temp = JSONAPI::Headers.new(test_input)
  #     expect(temp.get(:josh)).to be nil
  #     temp.add(:josh, 'demoss')
  #     expect(temp.get(:josh).vals).to eq 'demoss'
  #     expect(temp.get('josh').vals).to eq 'demoss'
  #     expect(temp.get('JoSH').vals).to eq 'demoss'
  #   end
  # end

  describe '#keys' do
    let(:headers) { JSONAPI::Headers.new(test_input) }

    it 'should return a list of the names of all the Header objects stored in Headers as lower case symbols' do
      expect(headers.keys).to eq %i[accept postman_token host content_type]
    end
  end

  describe '#to_s' do
    let(:headers) { JSONAPI::Headers.new(test_input) }
    to_string = '{:accept => application/vnd.api+json, ' \
                ':postman_token => 71160056-fbd7-4fb5-8031-914836b880fd, ' \
                ':host => localhost:8080, ' \
                ':content_type => application/vnd.api+json}'

    it 'should return an array of key/vals hashes as a string representing Headers contents' do
      expect(headers.to_s).to eq to_string
    end
  end

  describe JSONAPI::Headers::Header do
    let(:hdr) { JSONAPI::Headers::Header.new('josh', 'demoss') }
    describe '#to_s' do
      it 'should return a Header key and vals as "key => vals"' do
        expect(hdr.to_s).to eq 'josh => demoss'
      end
    end
  end
end
