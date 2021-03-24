# frozen_string_literal: true

require 'easy/jsonapi/request/query_param_collection/include_param'
require 'shared_examples/query_param_tests'

describe JSONAPI::Request::QueryParamCollection::IncludeParam do
  
  include_str_arr1 = [
    'author',
    'comments-likers.children',
    'comments-author-children',
    'sources-publisher.ceo-children'
  ]
  let(:i1) { JSONAPI::Request::QueryParamCollection::IncludeParam.new(include_str_arr1) }

  let(:value1) do
    {
      author: {
        included: true,
        relationships: {}
      },
      comments: {
        included: false,
        relationships: {
          likers: {
            included: true,
            relationships: {
              children: {
                included: true,
                relationships: {}
              }
            }
          },
          author: {
            included: false,
            relationships: {
              children: {
                included: true,
                relationships: {}
              }
            }
          }
        }
      },
      sources: {
        included: false,
        relationships: {
          publisher: {
            included: true,
            relationships: {
              ceo: {
                included: false,
                relationships: {
                  children: {
                    included: true,
                    relationships: {}
                  }
                }
              }
            }
          }
        }
      }
    }
  end

  include_str_arr2 = ['author', 'comments-likers', 'comments.author']
  let(:i2) { JSONAPI::Request::QueryParamCollection::IncludeParam.new(include_str_arr2) }
  
  let(:value2) do
    {
      author: {
        included: true,
        relationships: {}
      },
      comments: {
        included: true,
        relationships: {
          likers: {
            included: true,
            relationships: {}
          },
          author: {
            included: true,
            relationships: {}
          }
        }
      }
    }
  end


  it_behaves_like 'query param tests' do
    let(:pair) { i1 }
    let(:name) { 'includes' }
    let(:value) { value1 }
    let(:new_value_input) { value2 }
    let(:new_value) { value2 }
    to_string = 'include=author,comments-likers.children,comments-author-children,' \
                'sources-publisher.ceo-children'
    let(:to_str_orig) { to_string }
  end
end
