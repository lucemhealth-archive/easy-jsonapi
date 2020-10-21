# frozen_string_literal: true

require 'rack/jsonapi/item'
require 'rack/jsonapi/item/param'
require 'rack/jsonapi/item/param/field'
require 'rack/jsonapi/item/param/include'
require 'rack/jsonapi/item/param/page'
require 'rack/jsonapi/item/param/sort'
require 'rack/jsonapi/item/param/filter'

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
      
      # @param rack_req_params [Hash<String>] The parameter hash returned from Rack::Request.params
      # @return [JSONAPI::ParamCollection]
      def self.parse!(rack_req_params)
        
        # rack::request.params:
        # {
        #   "include"=>"author, comments.author",
        #   "fields"=>{"articles"=>"title,body,author", "people"=>"name"},
        #   "josh"=>"demoss",
        #   "page"=>{"offset"=>"1", "limit"=>"1"}
        # }
          
        param_collection = JSONAPI::Collection::ParamCollection.new
        rack_req_params.each do |key, value|
          add_the_param(key, value, param_collection)
        end
        param_collection
      end

      def self.add_the_param(key, value, param_collection)
        case key
        when 'include'
          param_collection.add(JSONAPI::Item::Param::Include.new(value))
        when 'fields'
          parse_fields_param(value, param_collection)
        when 'page'
          param_collection.add(JSONAPI::Item::Param::Page.new(value[:offset], value[:limit]))
        when 'sort'
          param_collection.add(JSONAPI::Item::Param::Sort.new(value))
        when 'filter'
          param_collection.add(JSONAPI::Item::Param::Filter.new(value))
        else
          param_collection.add(JSONAPI::Item::Param.new(key, value))
        end
      end

      def self.parse_fields_param(value, param_collection)
        value.each do |res, attributes|
          attr_arr = attributes.split(',')
          field_arr = attr_arr.map { |a| JSONAPI::Document::Data::Resource::Field.new(a, nil) }
          temp = JSONAPI::Item::Param::Field.new(res, field_arr)
          param_collection.add(temp)
        end
      end
    end
  end
end
