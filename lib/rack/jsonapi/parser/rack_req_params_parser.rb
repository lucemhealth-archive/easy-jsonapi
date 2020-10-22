# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/item/query_param'
require 'rack/jsonapi/item/query_param/field'
require 'rack/jsonapi/item/query_param/include'
require 'rack/jsonapi/item/query_param/page'
require 'rack/jsonapi/item/query_param/sort'
require 'rack/jsonapi/item/query_param/filter'

require 'rack/jsonapi/collection'
require 'rack/jsonapi/collection/param_collection'

require 'rack/jsonapi/document'
require 'rack/jsonapi/document/data/resource'
require 'rack/jsonapi/document/data/resource/field'

require 'rack/jsonapi/exceptions'
require 'rack/jsonapi/exceptions/params_exceptions'


module JSONAPI
  module Parser
    
    # Used to parse the request params given from the Rack::Request object
    module RackReqParamsParser
      
      # @query_param rack_req_params [Hash<String>] The parameter hash returned from Rack::Request.params
      # @return [JSONAPI::ParamCollection]
      def self.parse!(rack_req_params)
        
        # rack::request.params:
        # {
        #   "include"=>"author, comments.author",
        #   "fields"=>{"articles"=>"title,body,author", "people"=>"name"},
        #   "josh_ua"=>"demoss",
        #   "page"=>{"offset"=>"1", "limit"=>"1"}
        # }

        JSONAPI::Exceptions::ParamExceptions.check_compliance!(rack_req_params)
          
        param_collection = JSONAPI::Collection::ParamCollection.new
        rack_req_params.each do |key, value|
          add_the_param(key, value, param_collection)
        end
        param_collection
      end

      def self.add_the_param(key, value, param_collection)
        case key
        when 'include'
          param_collection.add(JSONAPI::Item::QueryParam::Include.new(value))
          # TODO: Fix issue with item already being included
          # resources = value.split(',')
          # resources.each do |res|
          #   include_obj = JSONAPI::Item::QueryParam::Include.new(res)
          #   param_collection.add(include_obj)
          # end
        when 'fields'
          parse_fields_param(value, param_collection)
        when 'page'
          param_collection.add(JSONAPI::Item::QueryParam::Page.new(value[:offset], value[:limit]))
        when 'sort'
          param_collection.add(JSONAPI::Item::QueryParam::Sort.new(value))
        when 'filter'
          param_collection.add(JSONAPI::Item::QueryParam::Filter.new(value))
        else
          param_collection.add(JSONAPI::Item::QueryParam.new(key, value))
        end
      end

      def self.parse_fields_param(value, param_collection)
        value.each do |res, attributes|
          attr_arr = attributes.split(',')
          field_arr = attr_arr.map { |a| JSONAPI::Document::Data::Resource::Field.new(a, nil) }
          temp = JSONAPI::Item::QueryParam::Field.new(res, field_arr)
          param_collection.add(temp)
        end
      end
    end
  end
end
