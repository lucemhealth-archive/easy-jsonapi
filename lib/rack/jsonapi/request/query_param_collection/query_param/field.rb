# frozen_string_literal: true

module JSONAPI
  class Request
    class QueryParamCollection
      class QueryParam
        # Used to create a unique Fieldset JSONAPI::Request::QueryParamCollection::QueryParam
        class Field < QueryParam
          
          # @param resource [String] The resource the JSONAPI::Resource::Fields belong to
          # @param res_fields_arr [Array<JSONAPI::Resource::Field>] An array containing the only 
          #   fields of a resource to include given the resource is returned in the server response.
          def initialize(resource, res_fields_arr)
            res_fields_arr = [res_fields_arr] unless res_fields_arr.is_a? Array
            unique_hash = "fields[#{resource}]"
            super(unique_hash, { resource: resource, fields: res_fields_arr })
          end
    
          # @return [String] The name of the resource 
          def resource
            @item[:value][:resource]
          end
          
          # @param new_resource [String | Symbol] The new resource
          def resource=(new_resource)
            @item[:value][:resource] = new_resource.to_s
          end
          
          # @return [Array<JSONAPI::Resource::Field>] The fields to include for a resource
          def fields
            @item[:value][:fields]
          end
          
          # @param new_fields [Array<JSONAPI::Resource::Field>] The new fields to include for a resource
          def fields=(new_fields)
            new_fields = [new_fields] unless new_fields.is_a? Array
            @item[:value][:fields] = new_fields
          end
          
          # @return The Field class represented as a string
          def to_s
            str_attr = fields.map(&:name)
            "fields[#{resource}] => { \"#{resource}\": \"#{str_attr.join(',')}\" }"
          end
    
          # #name provided by super class
    
          # Raise a runtime error if name is attempted to be reset
          # @param _ [Any]  given input.
          def name=(_)
            raise 'Cannot set the name of a Field object'
          end
    
          # Raise a runtime error if value is attempted to be accessed
          def value
            raise 'Field objects do not have a value method, try #resource or #fields'
          end
    
          # Raise a runtime error if value is attempted to be reset
          # @param _ [Any]  given input.
          def value=(_)
            raise 'Cannot set value of Field object, becausee Field does not have a value'
          end
          
        end
      end
    end
  end
end
