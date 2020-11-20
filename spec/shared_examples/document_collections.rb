# frozen_string_literal: true

require 'shared_examples/collection_like_classes'

shared_examples 'document collections' do
  it_behaves_like 'collection-like classes' do
  end

  describe '#to_h' do
    it 'should mimic a JSONAPI document' do
      expect(c.to_h).to eq to_hash
    end
  end
end
