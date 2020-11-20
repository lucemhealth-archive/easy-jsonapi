# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/query_param'
require 'rack/jsonapi/utility'

module JSONAPI
  class Request
    class QueryParamCollection < JSONAPI::NameValuePairCollection
      # The include query param
      class IncludeParam < QueryParam
        
        
        # @param includes_arr [Array<String>] An array with each individual query include
        #   Ex: incude=author,people => ['author', 'people']
        def initialize(includes_arr)
          includes_hash_structure = store_includes(includes_arr)
          super('includes', includes_hash_structure)
        end

        # to string
        def to_s
          "include=#{stringify_includes_hash(value)}"
        end

        private 

        # Represent include internal hash as query string
        # @param includes_hash [Hash] The internal structure
        def stringify_includes_hash(includes_hash)
          to_return = ''
          first = true
          includes_hash.each do |mem_name, mem_hash|
            if first
              to_return += to_s_mem(mem_name, mem_hash)
              first = false
            else
              to_return += ",#{to_s_mem(mem_name, mem_hash)}"
            end
          end
          to_return
        end

        # Depending on the delimiter stringify differently.
        # @param mem_name [Symbol] The name of the member to stringify
        # @param mem_hash [Hash] The information about that member
        def to_s_mem(mem_name, mem_hash)
          if mem_hash[:relationships] == {}
            mem_name.to_s
          else
            delimiter = mem_hash[:included] == true ? '.' : '-'
            prefix = "#{mem_name}#{delimiter}"
            to_return = ''
            first = true
            mem_hash[:relationships].each do |m_name, m_hash|
              if first
                to_return += "#{prefix}#{to_s_mem(m_name, m_hash)}"
                first = false
              else
                to_return += ",#{prefix}#{to_s_mem(m_name, m_hash)}"
              end
            end
            to_return
          end
        end

        # Helper for #initialize
        # @param includes_arr [Array<String>] The array of includes to store
        def store_includes(includes_arr)
          incl_hash = {}
          includes_arr.each do |include_str|
            include_str_arr = include_str.scan(/\w+|-|\./)
            store_include(incl_hash, include_str_arr)
          end
          incl_hash
        end

        # @param loc_in_h [Hash] The location within the main hash
        # @param i_arr [Array<String>] The array of include strings
        def store_include(loc_in_h, i_arr)
          res_name = i_arr[0].to_sym
          if i_arr.length == 1
            add_member(loc_in_h, res_name, included: true)
          else
            add_member(loc_in_h, res_name, included: res_included?(i_arr))
            store_include(loc_in_h[res_name][:relationships], i_arr[2..])
          end
        end

        # @param (see #store_include)
        def res_included?(i_arr)
          delim = i_arr[1]
          case delim
          when '.'
            true
          when '-'
            false
          else
            raise 'Syntax Error in include query string query param'
          end
        end

        # @param loc_in_h [Hash] The location within the main hash
        # @param res_name [Symbol] The name of the resource
        # @param included [TrueClass | FalseClass] Whether or not a resource
        #   is being requested or not
        def add_member(loc_in_h, res_name, included:)
          if loc_in_h.key?(res_name)
            loc_in_h[res_name][:included] = included unless included == false
          else
            loc_in_h[res_name] = {
              included: included,
              relationships: {}
            }
          end
        end
      end
    end
  end
end
