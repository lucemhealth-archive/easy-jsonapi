# frozen_string_literal: true

require 'rack/jsonapi/document/resource/field'

describe JSONAPI::Document::Resource::Field do

  let(:f1) { JSONAPI::Document::Resource::Field.new('number', type: Integer) }
  let(:f2) { JSONAPI::Document::Resource::Field.new('title') }

  describe '#initialize' do
    
    it 'should provide proper accessor methods' do
      expect(f1.name).to eq 'number'
      expect(f1.type).to eq Integer

      expect(f2.name).to eq 'title'
      expect(f2.type).to eq String

      f1.name = 'body'
      f1.type = String
      expect(f1.name).to eq 'body'
      expect(f1.type).to eq String

      f2.name = 'authors'
      f2.type = Array
      expect(f2.name).to eq 'authors'
      expect(f2.type).to eq Array
    end
  end
end
