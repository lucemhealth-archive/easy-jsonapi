# frozen_string_literal: true

module JSONAPI
  class Document

    # The jsonapi document 'included' top level member
    class Included

      attr_accessor :included

      def initialize(res_obj_arr)
        @included = res_obj_arr
      end
    end
  end
end
