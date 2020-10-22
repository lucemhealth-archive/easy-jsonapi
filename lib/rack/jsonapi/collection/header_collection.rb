# frozen_string_literal: true

module JSONAPI
  class Collection
    
    # header_collection # { include: Include, sort: Sort, filter: Filter } 
    class HeaderCollection < JSONAPI::Collection
      
      def initialize(header_arr = [])
        @header_types = []
        super(header_arr, &:name)
      end

      # #empyt? provided by super class
      # #include provided by super class

      def add(header)
        return unless header.is_a? JSONAPI::Header
        # add the header type unless it is already included
        @header_types << header.class.name unless @header_types.include?(header.class.name) || header.class.name == 'Header'
        super(header, &:name)
      end

      # #each provided from super class
      # #remove provided from super class
      # #get provided by super class
      # #keys provided by super class
      # #size provided by super class

      def to_s
        to_return = '{ '
        is_first = true
        each do |header|
          if is_first
            to_return += "#{header.to_s}"
            is_first = false
          else
            to_return += ", #{header}"
          end
        end
        to_return += ' }'
      end
      
      # def method_missing(method_name, *args, &block)
      #   # req.headers.includes == HeaderCollection.new([Include1, Include2])
      # end

      # def respond_to_missing?()
      # end

      # def<<(header)
      #   add(header)
      # end

      # private :insert
    
    end
  end  
end
