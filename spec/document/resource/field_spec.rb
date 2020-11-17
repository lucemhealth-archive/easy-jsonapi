# frozen_string_literal: true

require 'rack/jsonapi/field'

describe JSONAPI::Field do

  let(:f1) { JSONAPI::Field.new('number', type: Integer) }
  let(:f2) { JSONAPI::Field.new('title') }

  describe '#initialize' do
    
    it 'should provide proper accessor methods' do
      expect(f1.name).to eq 'number'
      expect(f1.type).to eq Integer

      expect(f2.name).to eq 'title'
      expect(f2.type).to eq String

      error_msg = 'Cannot change the name of a Resource::Field'
      expect { f1.name = 'body' }.to raise_error error_msg
      expect { f2.name = 'authors' }.to raise_error error_msg
      
      f1.type = String
      f2.type = Array
      expect(f1.type).to eq String
      expect(f2.type).to eq Array
    end
  end
end
