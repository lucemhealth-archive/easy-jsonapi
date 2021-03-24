# frozen_string_literal: true

require 'easy/jsonapi/utility'
require 'easy/jsonapi/document/resource/relationships'

module JSONAPI
  class Document
    class Resource
      class Relationships < JSONAPI::NameValuePairCollection
        # The relationships of a resource
        class Relationship
          attr_accessor :links, :data, :meta
          attr_reader :name

          # @param rels_member_hash [Hash] The hash of relationship members
          def initialize(rels_member_hash)
            unless rels_member_hash.is_a? Hash
              raise 'Must initialize a ' \
                    'JSONAPI::Document::Resource::Relationships::Relationship with a Hash'
            end
            # TODO: Knowing whether a relationship is to-one or to-many can assist in validating
            #   compliance and cross checking a document.
            @name = rels_member_hash[:name].to_s
            @links = rels_member_hash[:links]
            @data = rels_member_hash[:data]
            @meta = rels_member_hash[:meta]
          end

          # @return [String] A JSON parseable representation of a relationship
          def to_s
            "\"#{@name}\": { " \
              "#{JSONAPI::Utility.member_to_s('links', @links, first_member: true)}" \
              "#{JSONAPI::Utility.member_to_s('data', @data)}" \
              "#{JSONAPI::Utility.member_to_s('meta', @meta)}" \
            ' }' \
          end

          # Hash representation of a relationship
          def to_h
            { @name.to_sym => {
              links: @links.to_h,
              data: @data.to_h,
              meta: @meta.to_h
            } }
          end
        end
      end
    end
  end
end
