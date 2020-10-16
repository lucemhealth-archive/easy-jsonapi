# frozen_string_literal: true

require 'rack/jsonapi/exceptions/naming_exceptions'

describe JSONAPI::Exceptions::NamingExceptions do

  describe '#follows_member_constraints?' do
    it 'should return true when given valid input' do
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('test')).to be true
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('testEk')).to be true
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('test92sS')).to be true
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('te_st')).to be true
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('te-st')).to be true
    end
    
    it 'should return false when given invalid input' do
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('_test')).to be false
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('_test')).to be false
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('test_')).to be false
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('test!')).to be false
      expect(JSONAPI::Exceptions::NamingExceptions.follows_member_constraints?('(test)')).to be false
    end
  end
  
  describe '#follows_additional_constraints?' do
    it 'should return true when given valid input' do
      expect(JSONAPI::Exceptions::NamingExceptions.follows_additional_constraints?('teSt')).to be true
      expect(JSONAPI::Exceptions::NamingExceptions.follows_additional_constraints?('test1')).to be true
      expect(JSONAPI::Exceptions::NamingExceptions.follows_additional_constraints?('te_st')).to be true
      expect(JSONAPI::Exceptions::NamingExceptions.follows_additional_constraints?('te-st')).to be true
    end
    
    it 'should return false when given invalid input' do
      expect(JSONAPI::Exceptions::NamingExceptions.follows_additional_constraints?('test')).to be false
    end
  end
end
