# frozen_string_literal: true

require 'rack/jsonapi/exceptions/query_params_exceptions'

require 'rack/jsonapi/request/query_param_collection'

require 'rack/jsonapi/request/query_param_collection/query_param'

require 'rack/jsonapi/request/query_param_collection/filter_param'
require 'rack/jsonapi/request/query_param_collection/filter_param/filter'

require 'rack/jsonapi/request/query_param_collection/include_param'
require 'rack/jsonapi/request/query_param_collection/page_param'
require 'rack/jsonapi/request/query_param_collection/sort_param'

require 'rack/jsonapi/request/query_param_collection/fields_param'
require 'rack/jsonapi/request/query_param_collection/fields_param/fieldset'

require 'rack/jsonapi/field'

module JSONAPI
  module Parser
    
    # Used to parse the request params given from the Rack::Request object
    module RackReqParamsParser
      
      # @param rack_req_params [Hash<String>]  The parameter hash returned from Rack::Request.params
      # @return [JSONAPI::Request::QueryParamCollection]
      def self.parse!(rack_req_params)
        
        # rack::request.params: (string keys)
        # {
        #   'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
        #   'include' => 'author,comments-likers,comments.users',
        #   'josh_ua' => 'demoss,simpson',
        #   'page' => { 'offset' => '5', 'limit' => '20' },
        #   'filter' => { 'comments' => '(author/age > 21)', 'users' => '(age < 15)' },
        #   'sort' => 'age,title'
        # }

        query_param_collection = JSONAPI::Request::QueryParamCollection.new
        rack_req_params.each do |name, value|
          add_the_param(name, value, query_param_collection)
        end
        query_param_collection
      end

      def self.add_the_param(name, value, query_param_collection)
        case name
        when 'include'
          query_param_collection.add(parse_include_param(value))
        when 'fields'
          query_param_collection.add(parse_fields_param(value))
        when 'sort'
          query_param_collection.add(parse_sort_param(value))
        when 'page'
          query_param_collection.add(parse_page_param(value))
        when 'filter'
          query_param_collection.add(parse_filter_param(value))
        else
          query_param_collection.add(parse_query_param(name, value))
        end
      end

      def self.parse_include_param(value)
        includes_arr = value.split(',')
        JSONAPI::Request::QueryParamCollection::IncludeParam.new(includes_arr)
      end

      def self.parse_fields_param(value)
        fieldsets = []
        value.each do |res_type, res_field_str|
          res_field_str_arr = res_field_str.split(',')
          res_field_arr = res_field_str_arr.map { |res_field| JSONAPI::Field.new(res_field) }
          fieldsets << JSONAPI::Request::QueryParamCollection::FieldsParam::Fieldset.new(res_type, res_field_arr)
        end
        JSONAPI::Request::QueryParamCollection::FieldsParam.new(fieldsets)
      end

      def self.parse_sort_param(value)
        res_field_arr = value.split(',').map { |res_field| JSONAPI::Field.new(res_field) }
        JSONAPI::Request::QueryParamCollection::SortParam.new(res_field_arr)
      end

      def self.parse_page_param(value)
        JSONAPI::Request::QueryParamCollection::PageParam.new(offset: value[:offset], limit: value[:limit])
      end

      def self.parse_filter_param(value)
        
        filter_arr = value.map do |res_name, filter|
          JSONAPI::Request::QueryParamCollection::FilterParam::Filter.new(res_name, filter)
        end
        JSONAPI::Request::QueryParamCollection::FilterParam.new(filter_arr)
      end

      def self.parse_query_param(name, value)
        JSONAPI::Request::QueryParamCollection::QueryParam.new(name, value)
      end

      private_class_method :add_the_param, :parse_fields_param, :parse_include_param
    end
  end
end
