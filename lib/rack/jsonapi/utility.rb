# frozen_string_literal: true

module JSONAPI
  
  # A collection of resued logic throughout the gem.
  module Utility

    # Convert value to something that can be compared in a String vs Symbol, case, and
    #   '-' vs '_' insensitive way.
    # @param val [String | Symbol]
    def self.all_insensitive(val)
      val.to_s.downcase.gsub(/-/, '_')
    end

    # To hash method for a JSONAPI collection (like Attributes)
    # @param collection [Inumerable] The collection to hashify
    def self.to_h_collection(collection)
      to_return = {}
      collection.each do |mem|
        h_val = JSONAPI::Utility.to_h_value(mem)
        to_return[mem.name.to_sym] = h_val
      end
      to_return
    end
    
    # Helper method for #to_h_collection
    # @param val [Any] The value to call to hash on.
    # @return a hash value member
    def self.to_h_value(val)
      case val
      when String
        val
      when JSONAPI::Collection
        obj_hash = {}
        val.each { |i| obj_hash[i.name.to_sym] = to_h_value(i) }
        obj_hash
      else
        v = val.value
        case v
        when String
          to_h_value(v)
        when Array
          v.map { |e| to_h_value(e) }
        else
          v.to_h
        end
      end
    end

    # Helper for #to_h for classes that arent collection and have a set number
    #   of instance variables to hashify
    # @param hash_to_add_to [Hash] The hash to return
    # @param obj_member [Any] The instance variable to hashify
    # @param obj_member_name [Symbol] The hash key to store the object under
    # @return [Hash] The hash for a specific instance variable
    def self.to_h_member(hash_to_add_to, obj_member, obj_member_name)
      return if obj_member.nil?
      case obj_member
      when String
        hash_to_add_to[obj_member_name] = obj_member
      when Array
        hash_arr = obj_member.map(&:to_h)
        hash_to_add_to[obj_member_name] = hash_arr
      else
        hash_to_add_to[obj_member_name] = obj_member.to_h
      end
    end

    # Helper method for #to_s that stringifys a collection
    # @param collection [Inumerable] An array type of collection
    # @param delimiter [String] The delimieter to separate each item string
    # @param pre_string [String] The string to precede the collection string
    # @param post_string [String] The string to follow the collection
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

    # Helper for #to_s where collections are hashes and members should not
    #   be included if they are nil. It also accounts for arrays.
    # @param str_name [String | Symbol] The name of hash member
    # @param member [Any] The value of the hash member 
    # @param first_member [TrueClass | FalseClass] Whether or not this is the
    #   first member in the hash.
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
