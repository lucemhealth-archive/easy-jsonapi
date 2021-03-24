# frozen_string_literal: true

require 'easy/jsonapi/config_manager'
require 'easy/jsonapi/config_manager/config'

describe JSONAPI::ConfigManager::Config do
  
  let(:c) { JSONAPI::ConfigManager::Config.new }

  describe 'method_missing' do
    it 'should raise no MethodError when a non supported method is called' do
      expect { c.asdk }.to raise_error NoMethodError
    end
  end

  describe 'active?' do
    it 'should return true when no attributes have been set' do
      expect(c.required_document_members).to be nil
      expect(c.required_headers).to be nil
      expect(c.allow_client_ids).to be false
      expect(c.default?).to be true
    end

    
    it 'should return false when an attribute has been set' do
      c.allow_client_ids = true
      expect(c.default?).to be false
    end
  end
end
