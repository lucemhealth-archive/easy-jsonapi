# frozen_string_literal: true

require 'easy/jsonapi/utility'

describe JSONAPI::Utility do

  let(:u) { JSONAPI::Utility }
  
  describe '#to_h_collection' do
    # checked in specific classes they are used in
  end

  describe '#to_h_value' do
    # checked in specific classes they are used in
  end

  describe '#to_h_member' do
    # checked in specific classes they are used in
  end

  describe '#to_string_collection' do
    # checked in specific classes they are used in
  end

  describe '#member_to_s' do
    # checked in specific classes they are used in
  end

  describe '#array_to_s' do
    # checked in specific classes they are used in
  end

  describe '#path_to_res_type' do
    it 'should return the resource type given the path' do
      expect(u.path_to_res_type('/test/ing/person/123')).to eq 'person'
      expect(u.path_to_res_type('person')).to eq 'person'
      expect(u.path_to_res_type('person/6aa7fad8-6d1c-46d9-93fe-83d361155a80')).to eq 'person'
    end
    # assume valid path input bc invalid paths will not be routed to the server endpoints
  end

  describe '#integer?' do
    it 'should return true for valid integers' do
      expect(u.integer?(123)).to be true
      expect(u.integer?('123')).to be true
    end

    it 'should return false for invalid integers' do
      expect(u.integer?('123a')).to be false
      expect(u.integer?('b')).to be false
    end
  end

  describe '#valid_uuid?' do
    it 'should return false for a invalid uuid' do
      expect(u.uuid?(123)).to be false
      expect(u.uuid?('123-131a-1fs-1')).to be false
      expect(u.uuid?('aaaaaaaa-aaaa-aaaa-aaa-aaaaaaaa')).to be false
      expect(u.uuid?('666666666666666666666666666666666666')).to be false
      expect(u.uuid?('6Aa7fad8-6d1c-46d9-93fe-83d361155a80')).to be true
    end

    it 'should return true if a valid uuid' do
      expect(u.uuid?('6aa7fad8-6d1c-46d9-93fe-83d361155a80')).to be true
      expect(u.uuid?('6AA7FAD8-6D1C-46D9-93FE-83D361155A80')).to be true
    end
  end

  describe '#all_hash_path?' do
    it 'should return true for valid hash paths' do
      h = { test: { ing: 'ok' } }
      args = %i[test ing]
      expect(u.all_hash_path?(h, args)).to be true
    end

    it 'should return false for invalid hash paths' do
      h = { test: [:ing, 'ok'] }
      args = %i[test ing]
      expect(u.all_hash_path?(h, args)).to be false

      h = {}
      args = %i[test ing]
      expect(u.all_hash_path?(h, args)).to be false

      h = { test: 'ing' }
      args = %i[test ing]
      expect(u.all_hash_path?(h, args)).to be false

      h = { data: { type: "type" } }
      args = %i[data id]
      expect(u.all_hash_path?(h, args)).to be false
    end
  end
end
