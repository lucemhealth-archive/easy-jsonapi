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

        def to_s
          "include=#{stringify_includes_hash(value)}"
        end

        private 

        def stringify_includes_hash(includes_hash)
          to_return = ''
          first = true
          includes_hash.each do |mem_name, mem_hash|
            if first
              to_return += helper(mem_name, mem_hash)
              first = false
            else
              to_return += ",#{helper(mem_name, mem_hash)}"
            end
          end
          to_return
        end

        def helper(mem_name, mem_hash)
          if mem_hash[:relationships] == {}
            mem_name.to_s
          else
            delimiter = mem_hash[:included] == true ? '.' : '-'
            prefix = "#{mem_name}#{delimiter}"
            to_return = ''
            first = true
            mem_hash[:relationships].each do |m_name, m_hash|
              if first
                to_return += "#{prefix}#{helper(m_name, m_hash)}"
                first = false
              else
                to_return += ",#{prefix}#{helper(m_name, m_hash)}"
              end
            end
            to_return
          end
        end

        def store_includes(includes_arr)
          incl_hash = {}
          includes_arr.each do |include_str|
            include_str_arr = include_str.scan(/\w+|-|\./)
            store_include(incl_hash, include_str_arr)
          end
          incl_hash
        end

        def store_include(loc_in_h, i_arr)
          res_name = i_arr[0].to_sym
          if i_arr.length == 1
            add_member(loc_in_h, res_name, included: true)
          else
            add_member(loc_in_h, res_name, included: res_included?(i_arr))
            store_include(loc_in_h[res_name][:relationships], i_arr[2..])
          end
        end

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
