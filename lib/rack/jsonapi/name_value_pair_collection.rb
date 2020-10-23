# frozen_string_literal: true

require 'rack/jsonapi/collection'

module JSONAPI
  # The attributes of a resource
  class NameValuePairCollection < JSONAPI::Collection

    def initialize(pair_arr = [], class_type = NameValuePairCollection)
      @class_type = class_type 
      super(pair_arr, &:name)
    end

    # #empyt? provided by super
    # #include provided by super

    def add(pair)
      return unless pair.is_a? @class_type
      super(pair, &:name)
    end

    # Another way to add a query_param
    # @oaram (see #add)
    def <<(pair)
      add(pair)
    end

    # #each provided from super
    # #remove provided from super
    # #get provided by super
    # #keys provided by super
    # #size provided by super

    # def to_s
    #   to_return = '{ '
    #   is_first = true
    #   each do |pair|
    #     if is_first
    #       to_return += pair.to_s
    #       is_first = false
    #     else
    #       to_return += ", #{pair}"
    #     end
    #   end
    #   to_return += ' }'
    # end

    # Can't make insert private
    # private :insert
  end
end
