# frozen_string_literal: true

module JSONAPI
  class Request
    class QueryParamCollection
      class QueryParam
        # Used to create a unique Fieldset JSONAPI::Request::QueryParamCollection::QueryParam
        class Field < QueryParam
          
          # @query_param resource [String] The resource the JSONAPI::Resource::Fields belong to
          # @query_param res_fields [Array<JSONAPI::Resource::Field>] An array containing the only 
          #   fields of a resource to include given the resource is returned in the server response.
          def initialize(resource, res_fields_arr)
            res_fields_arr = [res_fields_arr] unless res_fields_arr.is_a? Array
            unique_hash = "fields[#{resource}]"
            super(unique_hash, { resource: resource, fields: res_fields_arr })
          end
    
          # @returns [String] The name of the resource 
          def resource
            @item[:value][:resource]
          end
          
          # @query_param [String | Symbol] The new name of the resource
          def resource=(new_resource)
            @item[:value][:resource] = new_resource.to_s
          end
          
          # @returns [Array<JSONAPI::Resource::Field>] The fields to include for a resource
          def fields
            @item[:value][:fields]
          end
          
          # @query_param new_resource [Array<JSONAPI::Resource::Field>] The new fields to include for a resource
          def fields=(new_attributes)
            new_attributes = [new_attributes] unless new_attributes.is_a? Array
            @item[:value][:fields] = new_attributes
          end
          
          # @returns The Field class represented as a string
          def to_s
            str_attr = fields.map(&:name)
            "fields[#{resource}] => { \"#{resource}\": \"#{str_attr.join(',')}\" }"
          end
    
          # #name provided by super class
    
          # Raise a runtime error if name is attempted to be reset
          # @query_param [Any] Any given input.
          def name=(_)
            raise 'Cannot set the name of a Field object'
          end
    
          # Raise a runtime error if value is attempted to be accessed
          def value
            raise 'Field objects do not have a value method, try #resource or #fields'
          end
    
          # Raise a runtime error if value is attempted to be reset
          # @query_param [Any] Any given input.
          def value=(_)
            raise 'Cannot set value of Field object, becausee Field does not have a value'
          end
          
        end
      end
    end
  end
end
