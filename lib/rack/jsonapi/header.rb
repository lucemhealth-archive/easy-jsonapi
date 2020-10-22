# frozen_string_literal: true

require 'rack/jsonapi/item/name_value_pair'

module JSONAPI
  
  # A http request or response header
  class Header < JSONAPI::Item::NameValuePair
  end
end
