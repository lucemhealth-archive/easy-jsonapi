# frozen_string_literal: true

require 'rack/jsonapi/name_value_pair'

describe JSONAPI::NameValuePair do

  let(:pair) { JSONAPI::NameValuePair.new(:name, 'value') }

  context '#initialize' do
    # it 'should not have any instance variables' do
    #   # pp pair.instance_variable_get(:@item)
    #   # pp pair.instance_variable_set(:@item, nil)
    #   # pp pair.instance_variable_get(:@item)
    #   expect(pair.instance_variables).to eq []
    # end
  end

  describe '#to_s' do
    it 'should work' do
      str = "\"name\": \"value\""
      expect(pair.to_s).to eq str
    end
  end

end
