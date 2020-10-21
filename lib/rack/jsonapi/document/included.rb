# frozen_string_literal: true

module JSONAPI
  class Document

    # The jsonapi document 'included' top level member
    class Included

      include Enumerable

      attr_accessor :included

      def initialize(res_obj_arr)
        @included = res_obj_arr
      end

      def each(&block)
        return @included.each { |res| block.call(res) } if block_given?
        to_enum(:each)
      end

      def to_s
        to_return = '['
        first = true
        @included.each do |incl_obj|
          if first
            to_return += incl_obj.to_s
            first = false
          else
            to_return += ", #{incl_obj}"
          end
        end
        to_return += ']'
      end
    end
  end
end
