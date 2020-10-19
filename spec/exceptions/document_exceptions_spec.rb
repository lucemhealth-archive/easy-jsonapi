# frozen_string_literal: true

require 'rack/jsonapi/exceptions/document_exceptions'

TOP_LEVEL_KEYS = %i[data errors meta].freeze
LINKS_KEYS = %i[self related first prev next last].freeze
LINK_KEYS = %i[href meta].freeze
RESOURCE_KEYS = %i[type id attributes relationships links meta].freeze
RELATIONSHIP_KEYS = %i[data links meta].freeze
RELATIONSHIP_LINK_KEYS = %i[self related].freeze

RESOURCE_IDENTIFIER_KEYS = %i[type id].freeze
JSONAPI_OBJECT_KEYS = %i[version meta].freeze
ERROR_KEYS = %i[id links status code title detail source meta].freeze

describe JSONAPI::Exceptions::DocumentExceptions do

  let(:ec) { JSONAPI::Exceptions::DocumentExceptions::InvalidDocument }

  let(:response_doc) do
    {
      "links": {
        "self": "http://example.com/articles",
        "next": "http://example.com/articles?page[offset]=2",
        "last": "http://example.com/articles?page[offset]=10"
      },
      "data": [{
        "type": "articles",
        "id": "1",
        "attributes": {
          "title": "JSON:API paints my bikeshed!"
        },
        "relationships": {
          "author": {
            "links": {
              "self": "http://example.com/articles/1/relationships/author",
              "related": "http://example.com/articles/1/author"
            },
            "data": { "type": "people", "id": "9" }
          },
          "comments": {
            "links": {
              "self": "http://example.com/articles/1/relationships/comments",
              "related": "http://example.com/articles/1/comments"
            },
            "data": [
              { "type": "comments", "id": "5" },
              { "type": "comments", "id": "12" }
            ]
          }
        },
        "links": {
          "self": "http://example.com/articles/1"
        }
      }],
      "included": [{
        "type": "people",
        "id": "9",
        "attributes": {
          "firstName": "Dan",
          "lastName": "Gebhardt",
          "twitter": "dgeb"
        },
        "links": {
          "self": "http://example.com/people/9"
        }
      }, {
        "type": "comments",
        "id": "5",
        "attributes": {
          "body": "First!"
        },
        "relationships": {
          "author": {
            "data": { "type": "people", "id": "2" }
          }
        },
        "links": {
          "self": "http://example.com/comments/5"
        }
      }, {
        "type": "comments",
        "id": "12",
        "attributes": {
          "body": "I like XML better"
        },
        "relationships": {
          "author": {
            "data": { "type": "people", "id": "9" }
          }
        },
        "links": {
          "self": "http://example.com/comments/12"
        }
      }]
    }
  end

  let(:req_doc) do 
    {
      "data": {
        "type": "photos",
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "attributes": {
          "title": "Ember Hamster",
          "src": "http://example.com/images/productivity.png"
        }
      }
    }
  end

  describe '#check_compliance!' do

    # **********************************
    # BASIC CHECKS
    # **********************************

    def f(response_doc, request: nil, post_request: nil)
      JSONAPI::Exceptions::DocumentExceptions.check_compliance!(response_doc, request: request, post_request: post_request)
    end

    it 'should raise a runtime error if !request but post_request' do
      expect { f(response_doc, request: false, post_request: true) }.to raise_error 'Cannot be a post request and not a request'
      expect(f(req_doc, post_request: true)).to be nil
    end

    it 'should raise when document is nil' do
      msg = 'Document is nil'
      expect { f(nil, request: true) }.to raise_error msg
      expect { f(nil) }.to raise_error msg
    end

    it 'should return nil if the document complies to all specs' do
      expect(f(response_doc)).to be nil      
      expect(f(req_doc, request: true)).to be nil      
      expect(f(req_doc, request: true, post_request: true)).to be nil  
    end


    # **********************************
    # CHECKING TOP LEVEL
    # **********************************
    describe '#check_top_level' do
      context 'when document does not contain one of the top level keys' do
        msg = 'A document MUST contain at least one of the following ' \
              "top-level members: #{TOP_LEVEL_KEYS}"

        it 'should raise when document contains other keys' do
          expect { f({ 'my_own_key': 'nothing' }) }.to raise_error(ec, msg)
          expect { f({ 'links': 'my_links' }) }.to raise_error(ec, msg)
        end
      end

      it 'should return nil when document contains one of the top level keys' do
        expect(f({ 'errors': { 'err1': '1' } })).to be nil
      end

    
      context 'when document is not a hash' do
        it 'should raise an error' do
          msg = 'A JSON object MUST be at the root of every JSON API request ' \
                'and response containing data'
          expect { f([], request: true) }.to raise_error(ec, msg)
          expect { f([]) }.to raise_error(ec, msg)
          expect { f(:asdj, request: true) }.to raise_error(ec, msg)
          expect { f(:asdj) }.to raise_error(ec, msg)
          expect { f(1234, request: true) }.to raise_error(ec, msg)
          expect { f(1234) }.to raise_error(ec, msg)
          expect { f('1234', request: true) }.to raise_error(ec, msg)
          expect { f('1234') }.to raise_error(ec, msg)
        end
      end

      context 'when document contains data member' do
        it 'should raise if errors key present with data key' do
          msg = 'The members data and errors MUST NOT coexist in the same document'
          expect { f({ 'data': { 'type': 'author' }, 'errors': 'error' }) }.to raise_error(ec, msg)
        end
      end

      context 'when document does not contain data member' do
        it 'should raise if included key present without data key' do
          msg = 'If a document does not contain a top-level data key, the included ' \
                'member MUST NOT be present either'
          expect { f({ 'meta': { 'meta_info': 'm' }, 'included': 'incl_objs' }) }.to raise_error(ec, msg)
        end

        context 'when document belongs to a request' do
          it 'should raise if no data member included' do
            msg = 'The request MUST include a single resource object as primary data'
            expect { f({ 'meta': { 'meta_info': 'm' } }, request: true) }.to raise_error(ec, msg)
          end
        end
      end
    end

    # **********************************
    # CHECKING MEMBERS:
    # **********************************
    describe '#check_members' do
      
      # CHECKING LINKS:
      context 'when checking links' do
        
        it 'should be a hash' do
          msg = 'A links object must be an object'
          expect { f({ data: {}, links: [] }) }.to raise_error(ec, msg)
        end

        it 'should only contain top level links keys' do
          msg = "The top-level links object May contain #{LINKS_KEYS}"
          links_obj_w_added_member = 
            {
              'test': 't',
              'self': 's',
              'related': 'r',
              'prev': 'p',
              'next': 'n',
              'first': 'f',
              'last': 'l'
            }
          links_obj = 
            {
              'self': 's',
              'related': 'r',
              'prev': 'p',
              'next': 'n',
              'first': 'f',
              'last': 'l'
            }
          expect { f({ data: { type: 'type', id: '123' }, links: links_obj_w_added_member }) }.to raise_error(ec, msg)
          expect(f({ data: { type: 'type', id: '123' }, links: links_obj })).to be nil
        end

        it 'should only contain link objs that are string or a hash w the right members' do
          bad_links_href =
            {
              'self': 's',
              'related': 
                {
                  'href': ['this, should, not, be, an array']
                }
            }
          bad_links_meta =
            {
              'self': 's',
              'related': 
                {
                  'href': 'this should be a string',
                  'meta': 'this should be a hash...'
                }
            }
          good_links =
            {
              'self': 's',
              'related': 
                {
                  'href': 'this should be a string',
                  'meta': { 'count': '1' }
                }
            }
          msg_href = 'The member href should be a string'
          msg_meta = 'The value of each meta member MUST be an object'
          expect { f({ data: { type: 'type', id: '123' }, links: bad_links_href }) }.to raise_error(ec, msg_href)
          expect { f({ data: { type: 'type', id: '123' }, links: bad_links_meta }) }.to raise_error(ec, msg_meta)
          expect(f({ data: { type: 'type', id: '123' }, links: good_links })).to be nil
        end
      end

      # CHECKING PRIMARY DATA:
      context 'when checking primary data' do
        it 'should raise if data not a hash when it is a request' do
          msg = 'The request MUST include a single resource object as primary data'
          expect { f({ meta: { 'count': 123 } }, request: true) }.to raise_error(ec, msg)
        end

        it 'should raise if not nil, a hash, or an array' do
          msg = 'Primary data must be either nil, an object or an array'
          expect { f({ data: 123 }) }.to raise_error(ec, msg)
          expect { f({ data: 'not_valid' }) }.to raise_error(ec, msg)
        end

        # -- CHECKING RESOURCE
        context 'when checking resource' do
          it "should raise if it is not a post request and it doesn't have an id member" do
            msg = 'Every resource object MUST contain an id member and a type member'
            expect { f({ data: { type: 'type' } }) }.to raise_error(ec, msg)
          end

          it 'should return nil if id is not included, but it is a post request' do
            expect(f({ data: { type: 'type' } }, post_request: true)).to be nil
          end

          it 'should raise if type is ever not included' do
            msg_post = 'The resource object (for a post request) MUST contain at least a type member'
            expect { f({data: {} }, post_request: true) }.to raise_error(ec, msg_post)
            msg_reg = 'Every resource object MUST contain an id member and a type member'
            expect { f({data: {} }) }.to raise_error(ec, msg_reg)
            expect { f({data: {} }, request: true) }.to raise_error(ec, msg_reg)
          end

          it 'should raise if resource contain any additional members' do
            msg = 'A resource object MAY only contain the following members: ' \
                  'type, id, attributes, relationships, links, meta'
            expect { f({ data: { type: 't', id: '123', test: 'test' } }) }.to raise_error(ec, msg)
          end

          it 'should raise if the type of id or type is not string' do
            msg_type = 'The value of the type member MUST be string'
            msg_id = 'The value of the id member MUST be string'
            expect { f({ data: { type: 123, id: '123' } }) }.to raise_error(ec, msg_type)
            expect { f({ data: { type: 't', id: 123 } }) }.to raise_error(ec, msg_id)
          end

          it 'it should raise if the value of type does not conform to member naming rules' do
            msg = 'The values of type members MUST adhere to the same constraints as member names'
            expect { f({ data: { type: '***type***', id: '123' } }) }.to raise_error(ec, msg)
          end

          # ----Checking Attributes
          context 'when checking attributes' do
            it 'should raise if attributes is not a hash' do
              msg = 'The value of the attributes key MUST be an object'
              expect { f({ data: { type: 't', id: '123', attributes: [] } }) }.to raise_error(ec, msg)
            end

            it 'should return nil if attributes is a hash' do
              expect(f({ data: { type: 't', id: '123', attributes: {} } })).to be nil
            end
          end

          # ----Checking Relationships
          context 'when checking relationships' do

            it 'should raise if relationships value is not a hash' do
              rel_not_hash = 
                {
                  data: {
                    type: 't',
                    id: '1',
                    relationships: [
                      author: {
                        data: { type: 't', id: '2' }
                      }
                    ]
                  }
                }
              msg = 'The value of the relationships key MUST be an object'
              expect { f(rel_not_hash) }.to raise_error(ec, msg)
            end
            
            it 'should raise if the value of any relationships key is not a hash' do
              rel_key_not_hash =
                {
                  data: {
                    type: 't',
                    id: '1',
                    relationships: {
                      author: [
                        data: { type: 't', id: '2' }
                      ]
                    }
                  }
                }
              msg = 'A relationship object must be an object'
              expect { f(rel_key_not_hash) }.to raise_error(ec, msg)
            end

            it 'should raise if a relationship does not contain one of the necessary keys' do
              rel_missing_keys =
                {
                  data: {
                    type: 't',
                    id: '1',
                    relationships: {
                      author: {}
                    }
                  }
                }
              msg = 'A relationship object MUST contain at least one of ' \
                    "#{RELATIONSHIP_KEYS}"
              expect { f(rel_missing_keys) }.to raise_error(ec, msg)
            end

            # ------CHECKING RELATIONSHIP MEMBERS
            context 'checking relationship members' do
              context 'checking data' do
                it 'should raise if data is not a hash array or nil' do
                  msg = 'Relationship data must be either nil, an object or an array'
                  expect { f({ data: { type: 't', id: '1', relationships: { author: { data: 'test' } } } }) }.to raise_error(ec, msg)
                end

                context 'checking resource id' do
                  it 'should raise if resource id is not a hash' do
                    rel_id_not_hash =
                      {
                        data: {
                          type: 't',
                          id: '1',
                          relationships: { author: { data: ['test', 'ing'] } }
                        }
                      }
                    msg = 'A resource identifier object must be an object'
                    expect { f(rel_id_not_hash) }.to raise_error(ec, msg)
                  end

                  it 'should raise if resource id does not contain type and id members' do
                    rel_no_id =
                      {
                        data: {
                          type: 't',
                          id: '1',
                          relationships: { author: { data: { type: 't' } } }
                        }
                      }
                    rel_no_type =
                      {
                        data: {
                          type: 't',
                          id: '1',
                          relationships: { author: { data: { id: '1' } } }
                        }
                      }
                    msg = 'A resource identifier object MUST contain type and id members'
                    expect { f(rel_no_id) }.to raise_error(ec, msg)
                    expect { f(rel_no_type) }.to raise_error(ec, msg)
                  end

                  it 'should raise if type or id value is not a string' do
                    rel_id_not_string =
                      {
                        data: {
                          type: 't',
                          id: '1',
                          relationships: { author: { data: { type: 't', id: 1 } } }
                        }
                      }
                    rel_type_not_string =
                      {
                        data: {
                          type: 't',
                          id: '1',
                          relationships: { author: { data: { type: ['t'], id: '1' } } }
                        }
                      }
                    msg_id = 'Member id must be a string'
                    msg_type = 'Member type must be a string'
                    expect { f(rel_id_not_string) }.to raise_error(ec, msg_id)
                    expect { f(rel_type_not_string) }.to raise_error(ec, msg_type)
                  end

                end
              end
            end

          end
        end

      end


    end

    # **********************************
    # CHECKING MEMBER NAMES
    # **********************************
    let(:bad_name_doc1) do
      {
        'data': 
          {
            'type': 'articles',
            'id': '1',
            'attributes': { '***title***': 'JSON API paints my bikeshed!' },
            'links': { 'self': 'http://example.com/articles/1' },
            'relationships': {
              'author': {
                'links': {
                  'self': 'http://example.com/articles/1/relationships/author',
                  'related': 'http://example.com/articles/1/author'
                },
                'data': { 'type': 'people', 'id': '9' }
              }
            }
          },
        'meta': { 'count': '13' }
      }
    end

    let(:bad_name_doc2) do
      {
        'data': 
          {
            'type': 'articles',
            'id': '1',
            'attributes': { 'title': 'JSON API paints my bikeshed!' },
            'links': { 'self': 'http://example.com/articles/1' },
            'relationships': {
              '***author***': {
                'links': {
                  'self': 'http://example.com/articles/1/relationships/author',
                  'related': 'http://example.com/articles/1/author'
                },
                'data': { 'type': 'people', 'id': '9' }
              }
            }
          },
        'meta': { 'count': '13' }
      }
    end
    
    let(:bad_name_doc3) do
      {
        'data': 
          {
            'type': 'articles',
            'id': '1',
            'attributes': { 'title': 'JSON API paints my bikeshed!' },
            'links': { 'self': 'http://example.com/articles/1' },
            'relationships': {
              "author": {
                "links": {
                  "self": "http://example.com/articles/1/relationships/author",
                  "related": "http://example.com/articles/1/author"
                },
                "data": { "type": "people", "id": "9" }
              },
              "***comments***": {
                "links": {
                  "self": "http://example.com/articles/1/relationships/comments",
                  "related": "http://example.com/articles/1/comments"
                },
                "data": [
                  { "type": "comments", "id": "5" },
                  { "type": "comments", "id": "12" }
                ]
              }
            }
          },
        'meta': { 'count': '13' }
      }
    end

    describe '#check_member_names!' do
    
      it 'should raise with the appropriate message when a bad member name exists' do
        msg = "The ***title*** member did not follow member name constraints"
        expect { JSONAPI::Exceptions::DocumentExceptions.check_member_names!(bad_name_doc1) }.to raise_error(ec, msg)
        msg = "The ***author*** member did not follow member name constraints"
        expect { JSONAPI::Exceptions::DocumentExceptions.check_member_names!(bad_name_doc2) }.to raise_error(ec, msg)
        msg = "The ***comments*** member did not follow member name constraints"
        expect { JSONAPI::Exceptions::DocumentExceptions.check_member_names!(bad_name_doc3) }.to raise_error(ec, msg)
      end

      it 'should return nil given a correct document' do
        expect(JSONAPI::Exceptions::DocumentExceptions.check_member_names!(response_doc)).to be nil
      end
    end
  end
    
  #   context 'when testing the data key for errors' do
  #     it 'should return nil if data is not present in a non_request document' do
  #       expect(f({ 'meta': { 'meta_info': 'm' } })).to be nil
  #     end

  #     context 'request is true' do
  #       it 'should raise if data is an array' do
  #         expect { f({ 'data': ['test', 'ing'] }, request: true) }.to raise_error(ec, msg)
  #       end
  #     end
      
  #     context 'data is neither an array, nor a hash, nor nil' do
  #       it 'should raise ' do
  #         expect { f({ 'data': 'test' }) }.to raise_error(ec, msg)
  #         expect { f({ 'data': 'test' }, request: true) }.to raise_error(ec, msg)
  #       end
  #     end
  #   end

  #   context 'when checking resource objects for errors' do
  #     context 'when not a post request' do
  #       it 'should raise if id or type is missing' do
  #         expect { f({ 'data': { 'not_id': '1', 'not_type': 'test' } }, request: true) }.to raise_error(ec, msg)
  #         expect { f({ 'data': { 'not_id': '1', 'type': 'test' } }, request: true) }.to raise_error(ec, msg)
  #         expect { f({ 'data': { 'id': '1', 'not_type': 'test' } }, request: true) }.to raise_error(ec, msg)
  #       end
  #     end
      
  #     context 'when a post request' do
  #       it 'should raise if type is missing' do
  #         expect { f({ 'data': { 'not_type': 'test' } }, post_request: true) }.to raise_error(ec, msg)
  #       end
  #     end

  #     context 'when testing type and id values' do
  #       it 'should raise if id is present and the type of the value is not string' do
  #         expect { f({ 'data': { 'type': 'test', 'id': 123 } }, post_request: true) }.to raise_error(ec, msg)
  #         expect { f({ 'data': { 'type': 'test', 'id': 123 } }, request: true) }.to raise_error(ec, msg)
  #         expect { f({ 'data': { 'type': 'test', 'id': 123 } }) }.to raise_error(ec, msg)
  #       end
        
  #       it 'should raise if the value of type is not string' do
  #         expect { f({ 'data': { 'type': 123 } }) }.to raise_error(ec, msg)
  #         expect { f({ 'data': { 'type': 123 } }, request: true) }.to raise_error(ec, msg)
  #         expect { f({ 'data': { 'type': 123 } }, post_request: true) }.to raise_error(ec, msg)
  #       end
        
  #       it 'should return nil if type and id are present when necessary and are of type string' do
  #         expect(f({ 'data': { 'type': 'test', 'id': '1' } })).to be nil
  #         expect(f({ 'data': { 'type': 'test', 'id': '1' } }, request: true)).to be nil
  #         expect(f({ 'data': { 'type': 'test', 'id': '1' } }, post_request: true)).to be nil
  #         expect(f({ 'data': { 'type': 'test' } }, post_request: true)).to be nil
  #       end
  #     end

  #     context 'when testing data keys' do
        
  #       let(:good_data) do
  #         {
  #           'data' =>
  #             {
  #               'type': 'test',
  #               'id': '1',
  #               'attributes': { 'name': 'a' },
  #               'relationships': { 'rel': { 'r': 'el' } },
  #               'meta': { 'met': 'm' },
  #               'links': { 'link': 'l' }
  #             }
  #         }
  #       end
      
  #       let(:bad_data) do
  #         {
  #           'data' =>
  #             {
  #               'type': 'test',
  #               'id': '1',
  #               'attributes': 'a',
  #               'relationships': 'r',
  #               'meta': 'm',
  #               'links': 'l',
  #               'extra_member': 'error'
  #             }
  #         }
  #       end
        
  #       it 'should raise if non resource members are present' do
  #         expect { f(bad_data) }.to raise_error(ec, msg)
  #       end

  #       it 'should return nil when only resource members are present' do
  #         expect(f(good_data)).to be nil
  #       end
  #     end

  #     context 'when testing attributes' do
  #       it 'should raise if attributes is not a hash' do
  #         expect { f({ 'data': { 'type': 't', 'id': '1', 'attributes': 'name' } }) }.to raise_error(ec, msg)
  #       end

  #       it 'should return nil if formatted correctly' do
  #         expect(f({ 'data': { 'type': 't', 'id': '1', 'attributes': { 'name': 'test' } } })).to be nil
  #       end
  #     end
  #   end
  # end



  # ****************************************
  # TESTING PRIVATE CLASS METHODS -- NEED TO COMMENT OUT PRIVATE DECLARATION IN document_exceptions.rb


  
  
  # ************************************






  # it 'succeeds on nil data' do
  #   payload = { 'data': nil }

  #   expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  # end

  # it 'succeeds on empty array data' do
  #   payload = { 'data': [] }

  #   expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  # end

  # it 'works' do
  #   payload = 

  #   expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  # end

  # it 'passes regardless of id/type order' do
  #   payload = {
  #     'data': [
  #       {
  #         'type': 'articles',
  #         'id': '1',
  #         'relationships': {
  #           'comments': {
  #             'data': [
  #               { 'type': 'comments', 'id': '5' },
  #               { 'id': '12', 'type': 'comments' }
  #             ]
  #           }
  #         }
  #       }
  #     ]
  #   }

  #   expect { JSONAPI.parse_response!(payload) }.to_not raise_error
  # end

  # it 'fails when an element is missing type or id' do
  #   payload = {
  #     'data': [
  #       {
  #         'type': 'articles',
  #         'id': '1',
  #         'relationships': {
  #           'author': {
  #             'data': { 'type': 'people' }
  #           }
  #         }
  #       }
  #     ]
  #   }

  #   expect { JSONAPI.parse_response!(payload) }.to raise_error(
  #     JSONAPI::Parser::,
  #     'A resource identifier object MUST contain ["id", "type"] members'
  #   )
  # end
  
end
