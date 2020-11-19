# frozen_string_literal: true

shared_examples 'name value and query shared tests' do
  context '#initialize' do
    it 'should inherit methods and variables of the super class' do
      expect(pair.is_a?(JSONAPI::Item)).to be true
    end
  end

  context 'testing accessor methods' do
    it 'should be able to retrieve name and value' do
      expect(pair.name).to eq name
      expect(pair.value).to eq value
    end

    it 'should be able to update name and value' do
      pair.value = new_value
      expect { pair.name = 'new_name' }.to raise_error name_error_msg
      expect(pair.value).to eq new_value
    end
  end

  context 'checking scope' do
    it 'should not be able to access parent private methods' do
      expect { pair.ensure_keys_are_sym({ name: name }) }.to raise_error NoMethodError
      expect { pair.should_update_var?(:name) }.to raise_error NoMethodError
      expect { pair.should_get_var?(:name) }.to raise_error NoMethodError
    end

    it 'should return NoMethodError when calling private methods' do
      expect { pair.method_missing(:no_method) }.to raise_error NoMethodError
      expect { pair.pair }.to raise_error NoMethodError
      expect { pair.pair = 5 }.to raise_error NoMethodError
    end
  end
  
  describe '#to_s' do
    it 'should work' do
      expect(pair.to_s).to eq to_str_orig
    end
  end
end
