# frozen_string_literal: true

require 'rack/jsonapi/request/query_param_collection/include_param'

describe JSONAPI::Request::QueryParamCollection::IncludeParam do
  
  include_str_arr1 = ['author', 'comments-likers', 'comments.author']
  let(:i1) { JSONAPI::Request::QueryParamCollection::IncludeParam.new(include_str_arr1) }
  
  include_str_arr2 = [
    'author',
    'comments-likers.children',
    'comments-author-children',
    'sources-publisher.ceo-children'
  ]
  let(:i2) { JSONAPI::Request::QueryParamCollection::IncludeParam.new(include_str_arr2) }

  let(:value1) do
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

  let(:value2) do
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

  it 'should have appropriate accessor methods' do
    expect(i1.name).to eq 'include'
    expect(i2.name).to eq 'include'
    
    expect(i1.value).to eq value1
    expect(i2.value).to eq value2
    
    i1.value = {}
    i2.value = value1
    
    expect(i1.value).to eq({})
    expect(i2.value).to eq(value1)
  end

  it 'should have an intuitive #to_s method' do
    expect(i1.to_s).to eq 'include=author,comments.likers,comments.author'
    
    to_string = 'include=author,comments-likers.children,comments-author-children,' \
                'sources-publisher.ceo-children'
    expect(i2.to_s).to eq to_string
  end
end
