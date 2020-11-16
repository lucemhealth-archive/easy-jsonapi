# frozen_string_literal: true

require 'rack/jsonapi/document'

module JSONAPI

  # A abstract document from the point of view of a developer. He or she only cares about
  #   adding resources and adding 
  class UserDocument

    def initialize(members_hash = {})
      @data = members_hash[:data] || {}
      @meta = members_hash[:meta] || {}
    end

    # add primary resource(s)
    def add_resource(resource)
      k = key_from_resource(resource)
      @data[k] = resource
    end

    # delete resource(s)
    def delete_resource(type, id)
      k = "#{type}|#{id}".to_sym
      @data.delete(k)
    end

    # returns the collection of resources
    def resources
      @data.values
    end

    # include additional resource(s)
    # delete additional resource(s)
    # sparse fieldsets should only be on serverside

  end
end

# GET /articles?include=author&fields[name]

# Response:
# Add primary resource
# add included resources
# only include name attribute in resource
