# frozen_string_literal: true

require 'easy/jsonapi/document/resource_id'

describe JSONAPI::Document::ResourceId do

  let(:res_id) { JSONAPI::Document::ResourceId.new(type: 'people', id: '1') }

  it 'should have proper accessor methods' do
    expect(res_id.type).to eq 'people'
    expect(res_id.id).to eq '1'
  end

  it 'should have an intuitive #to_s' do
    to_string = "{ \"type\": \"people\", \"id\": \"1\" }"
    expect(res_id.to_s).to eq to_string
  end

  it 'should have a working #to_h' do
    expect(res_id.to_h).to eq({ type: 'people', id: '1' })


  end
end
