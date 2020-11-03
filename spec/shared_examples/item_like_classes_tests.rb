# frozen_string_literal: true

shared_examples 'item like classes' do
  context '#initialize' do
    it 'should inherit methods and variables of the super class' do
      expect(item.is_a?(JSONAPI::Item)).to be true
    end
  end

  context 'testing accessor methods' do
    it 'should be able to retrieve name and value' do
      expect(item.name).to eq 'name'
      expect(item.value).to eq 'value'
    end

    it 'should be able to update name and value' do
      item.name = 'new_name'
      item.value = 'new_value'
      expect(item.name).to eq 'new_name'
      expect(item.value).to eq 'new_value'
    end
  end

  context 'checking scope' do
    it 'should not be able to access parent private methods' do
      expect { item.ensure_keys_ar_sym!({ name: 'name' }) }.to raise_error NoMethodError
      expect { item.should_update_var?(:name) }.to raise_error NoMethodError
      expect { item.should_get_var?(:name) }.to raise_error NoMethodError
    end
  end
  
  describe '#to_s' do
    it 'should work' do
      str = "{ \"name\": \"name\", \"value\": \"value\" }"
      expect(item.to_s).to eq str
    end
  end
end
