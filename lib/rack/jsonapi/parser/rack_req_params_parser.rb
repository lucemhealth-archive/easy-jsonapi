# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/request/query_param_collection/query_param'
require 'rack/jsonapi/request/query_param_collection/query_param/field'
require 'rack/jsonapi/request/query_param_collection/query_param/include'
require 'rack/jsonapi/request/query_param_collection/query_param/page'
require 'rack/jsonapi/request/query_param_collection/query_param/sort'
require 'rack/jsonapi/request/query_param_collection/query_param/filter'

require 'rack/jsonapi/collection'
require 'rack/jsonapi/request/query_param_collection'

require 'rack/jsonapi/document'
require 'rack/jsonapi/document/resource'
require 'rack/jsonapi/document/resource_id'
require 'rack/jsonapi/document/resource/field'

require 'rack/jsonapi/exceptions/query_params_exceptions'


module JSONAPI
  module Parser
    
    # Used to parse the request params given from the Rack::Request object
    module RackReqParamsParser
      
      # @param rack_req_params [Hash<String>]  The parameter hash returned from Rack::Request.params
      # @return [JSONAPI::Request::QueryParamCollection]
      def self.parse!(rack_req_params)
        
        # rack::request.params: (string keys)
        # {
        #   "include"=>"author, comments.author",
        #   "fields"=>{"articles"=>"title,body,author", "people"=>"name"},
        #   "josh_ua"=>"demoss",
        #   "page"=>{"offset"=>"1", "limit"=>"1"}
        # }

        JSONAPI::Exceptions::QueryParamsExceptions.check_compliance!(rack_req_params)
          
        query_param_collection = JSONAPI::Request::QueryParamCollection.new
        rack_req_params.each do |key, value|
          add_the_param(key, value, query_param_collection)
        end
        query_param_collection
      end

      def self.add_the_param(key, value, query_param_collection)
        case key
        when 'include'
          parse_include_param(value, query_param_collection)
        when 'fields'
          parse_fields_param(value, query_param_collection)
        when 'page'
          query_param_collection.add(JSONAPI::Request::QueryParamCollection::QueryParam::Page.new(value[:offset], value[:limit]))
        when 'sort'
          query_param_collection.add(JSONAPI::Request::QueryParamCollection::QueryParam::Sort.new(value))
        when 'filter'
          query_param_collection.add(JSONAPI::Request::QueryParamCollection::QueryParam::Filter.new(value))
        else
          query_param_collection.add(JSONAPI::Request::QueryParamCollection::QueryParam.new(key, value))
        end
      end

      def self.parse_include_param(value, query_param_collection)
        # TODO: Need to talk to Joe ab multiple QueryParams.
        resources = value.split(', ')
        resources.each do |res|
          include_obj = JSONAPI::Request::QueryParamCollection::QueryParam::Include.new(res)
          query_param_collection.add(include_obj)
        end
      end

      def self.parse_fields_param(value, query_param_collection)
        value.each do |res, attributes|
          attr_arr = attributes.split(',')
          field_arr = attr_arr.map { |a| JSONAPI::Document::Resource::Field.new(a) }
          param_field = JSONAPI::Request::QueryParamCollection::QueryParam::Field.new(res, field_arr)
          query_param_collection.add(param_field)
        end
      end

      private_class_method :add_the_param, :parse_fields_param, :parse_include_param
    end
  end
end
