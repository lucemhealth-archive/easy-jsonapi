# frozen_string_literal: true

module JSONAPI
  
  # A collection of resued logic throughout the gem.
  module Utility

    def self.to_string_collection(collection, delimiter: ', ', pre_string: '', post_string: '')
      to_return = pre_string
      first = true
      collection.each do |item|
        if first
          to_return += item.to_s
          first = false
        else
          to_return += "#{delimiter}#{item}"
        end
      end
      to_return += post_string
    end
  end
end
