# frozen_string_literal: true

module JSONAPI
  
  # A collection of resued logic throughout the gem.
  module Utility

    def self.to_string_collection(collection, delimiter: ', ', pre_string: '', post_string: '')
      to_return = pre_string
      first = true
      collection.each do |item|
        if first
          to_return += item.to_s
          first = false
        else
          to_return += "#{delimiter}#{item}"
        end
      end
      to_return += post_string
    end

    def self.member_to_s(str_name, member, first_member: false)
      return '' if member.nil?
      member = "\"#{member}\"" if member.is_a? String
      if first_member
        "\"#{str_name}\": #{array_to_s(member)}"
      else
        ", \"#{str_name}\": #{array_to_s(member)}"
      end
    end

    # Returns the proper to_s for members regardless of 
    #   whether they are stored as an array or member object
    def self.array_to_s(obj_arr)
      return obj_arr.to_s unless obj_arr.is_a? Array
      to_return = '['
      first = true
      obj_arr.each do |obj|
        if first
          to_return += obj.to_s
          first = false
        else
          to_return += ", #{obj}"
        end
      end
      to_return += ']'
    end
  end
end
