# frozen_string_literal: true

require 'easy/jsonapi/config_manager'

class ItemThatRaisesError

  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

describe JSONAPI::ConfigManager do
  let(:cm) { JSONAPI::ConfigManager.new }

  let(:config) { JSONAPI::ConfigManager::Config.new }
  
  let(:config_class) { JSONAPI::ConfigManager::Config }

  let(:res_type) { 'ex_res_type' }

  describe '#initialize' do
    it 'should be set to default' do
      expect(cm.default?).to eq true
    end
  end

  describe '#each' do
    context 'config_manager should respond to enumerable methods' do
      
      it 'should respond to #first' do
        expect(cm.respond_to?(:first)).to eq true
      end

      it 'should respond to #filter' do
        expect(cm.respond_to?(:filter)).to eq true
      end

      it 'should return an Enumerator when no block is passed' do
        expect(cm.each.class).to eq Enumerator
      end

      it 'should be iterating over config objects and the keys should be symbols' do
        checker = true
        cm.each do |res_type, config| 
          cur_class = config.class
          checker = ((cur_class == config_class) && res_type.instance_of?(Symbol) && checker)
        end
        expect(checker).to eq true
      end
    end
  end

  describe '#default?' do
    it 'should return true when no attribute has been set on any config' do
      expect(cm.default?).to be true
    end

    it 'should return false when an attribute is set on the global config' do
      cm.global.allow_client_ids = true
      expect(cm.default?).to be false
    end

    it 'should return false when an attribute is set on a resource config' do
      cm[res_type] = config
      cm[res_type].allow_client_ids = true
      expect(cm.default?).to be false
    end
  end

  describe '#include?' do
    it 'should state whether a config is in the ConfigManager' do
      expect(cm.include?(:global)).to be true
      expect(cm.include?(res_type)).to be false
    end

    it 'should be case sensitive for checking the name' do
      expect(cm.include?(res_type.to_s)).to be false
      expect(cm.include?(res_type.to_sym)).to be false
      expect(cm.include?(res_type.upcase)).to be false
      cm.add(res_type, config)
      expect(cm.include?(res_type.to_s)).to be true
      expect(cm.include?(res_type.to_sym)).to be true
      expect(cm.include?(res_type.upcase)).to be false
    end
  end

  describe '#add' do
    it 'should make #default? return false' do
      expect(cm.default?).to be true
      config.allow_client_ids = true
      cm.add(res_type, config)
      expect(cm.default?).to be false
    end

    it 'should add items to the config_manager' do
      expect(cm.default?).to be true
      cm.add(res_type, config)
      expect(cm.include?(res_type)).to be true
    end

    it 'should raise if adding an item different than specified type' do
      bad_item = ItemThatRaisesError.new('bad_item')
      error_msg = "Cannot add a config that is not #{config_class}"
      expect { cm.add(res_type, bad_item) }.to raise_error error_msg
    end
  end
  
  describe '#insert' do
    it 'should raise when inserting a config that already exists for a resource type' do
      cm.add(res_type, config)
      err_msg = "The resource type: #{res_type}, already has an config associated with it. " \
                'Remove existing config first.'
      expect { cm.insert(res_type, config) }.to raise_error err_msg
    end

    it 'should add a config when given an unused resource type' do
      expect(cm[res_type]).to be nil
      cm.insert(res_type, config)
      expect(cm[res_type]).to eq config
    end
  end

  describe '#set and #[]=' do

    it 'should create a key if it does not exist' do
      expect(cm.get(res_type)).to be nil
      cm.set(res_type, config)
      expect(cm.get(res_type)).to eq config
      
      cm.remove(res_type)
      expect(cm.get(res_type)).to be nil
      cm[res_type] = config
      expect(cm.get(res_type)).to eq config
    end

    it 'should overwrite the value of a key if the key exists already ' do
      cm.set(res_type, config)
      new_config = config.clone
      cm.set(res_type, new_config)
      expect(config.object_id).not_to eq new_config.object_id
      expect(cm.get(res_type)).to eq new_config
      
      cm[res_type] = config
      new_config = config.clone
      cm[res_type] = new_config
      expect(config.object_id).not_to eq new_config.object_id
      expect(cm.get(res_type)).to eq new_config
    end
  end

  describe '#get and #[]' do
    
    it 'should return nil if the config_manager does not contain the item' do
      expect(cm.get('te_st')).to eq nil
    end
    
    it 'should return the appropriate config' do
      expect(cm.get(:global).is_a?(config_class)).to be true
      expect(cm[:global].is_a?(config_class)).to be true
    end

    it 'should be case sensitive but work for both symbol or string' do
      cm.add(res_type, config)
      c = cm.get(res_type)
      expect(cm.get(res_type.to_s)).to eq c
    end
  end

  describe '#remove' do
    it 'should return nil if the key is not in the config_manager' do
      expect(cm.include?('te_st')).to be false
      expect(cm.remove('te_st')).to eq nil
    end

    it 'should raise if user tries to remove the global config' do
      err_msg = 'Cannot remove global config'
      expect { cm.remove(:global) }.to raise_error err_msg
    end

    it 'should remove configs from the config_manager' do
      cm.add(res_type, config)
      expect(cm.include?(res_type)).to be true
      c = cm.remove(res_type)
      expect(cm.include?(res_type)).to be false
      expect(c.is_a?(config_class)).to be true
    end
  end

  describe '#size' do
    it 'should return the number of configs in the config_manager' do
      expect(cm.size).to eq 0
    end
  end

  describe '#configs' do
    it 'should return the name of the configs active in the config manager' do
      expect(cm.configs).to eq []
      cm.global.allow_client_ids = true
      expect(cm.configs).to eq [:global]
      cm[res_type] = config
      expect(cm.configs).to eq [:global]
      cm[res_type].allow_client_ids = true
      expect(cm.configs).to eq %i[global ex_res_type]
    end
  end

  describe '#to_s' do
    it "should return an array of name/vals hashes as a string representing config_manager's contents" do
      c = cm.global
      expect(cm.to_s).to eq "{ global: #{c} }"
    end
  end
end
