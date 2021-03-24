# frozen_string_literal: true

require 'easy/jsonapi/exceptions/naming_exceptions'

describe JSONAPI::Exceptions::NamingExceptions do

  # A alias method
  # @param name [String | Symbol] The member name to check
  def check_member_constraints(name)
    JSONAPI::Exceptions::NamingExceptions.check_member_constraints(name)
  end

  describe '#check_member_constraints' do
    it 'should return true when given valid input' do
      expect(check_member_constraints('test')).to be nil
      expect(check_member_constraints('testEk')).to be nil
      expect(check_member_constraints('test92sS')).to be nil
      expect(check_member_constraints('te_st')).to be nil
      expect(check_member_constraints('te-st')).to be nil
    end
    
    it 'should raise when given invalid input' do
      expect(check_member_constraints('_test').class).to eq String
      expect(check_member_constraints('test_').class).to eq String
      expect(check_member_constraints('test!').class).to eq String
      expect(check_member_constraints('(test)').class).to eq String
    end
  end
  
  # A alias method
  # @param name [String | Symbol] The member name to check for additional constraints
  def check_additional_constraints(name)
    JSONAPI::Exceptions::NamingExceptions.check_additional_constraints(name)
  end

  describe '#check_additional_constraints' do
    it 'should return nil when given valid input' do
      expect(check_additional_constraints('teSt')).to be nil
      expect(check_additional_constraints('test1')).to be nil
      expect(check_additional_constraints('te_st')).to be nil
      expect(check_additional_constraints('te-st')).to be nil
    end
    
    it 'should raise when given invalid input' do
      expect(check_additional_constraints('test').class).to eq String
    end
  end
end
