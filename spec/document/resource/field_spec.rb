# frozen_string_literal: true

require 'rack/jsonapi/document/resource/field'

describe JSONAPI::Document::Resource::Field do

  let(:f1) { JSONAPI::Document::Resource::Field.new('title', 'a good read') }
  let(:f2) { JSONAPI::Document::Resource::Field.new('body') }

  describe '#initialize' do
    
    it 'should provide proper accessor methods' do
      expect(f1.name).to eq 'title'
      expect(f1.value).to eq 'a good read'

      expect(f2.name).to eq 'body'
      expect(f2.value).to eq nil
    end
  end
end
