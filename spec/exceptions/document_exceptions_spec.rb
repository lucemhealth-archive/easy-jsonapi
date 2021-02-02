# frozen_string_literal: true

require 'rack/jsonapi/exceptions/document_exceptions'
require 'shared_contexts/document_exceptions_shared_context'

TOP_LEVEL_KEYS = %i[data errors meta].freeze
LINKS_KEYS = %i[self related first prev next last].freeze
LINK_KEYS = %i[href meta].freeze
RESOURCE_KEYS = %i[type id attributes relationships links meta].freeze
RELATIONSHIP_KEYS = %i[data links meta].freeze
RELATIONSHIP_LINK_KEYS = %i[self related].freeze
RESOURCE_IDENTIFIER_KEYS = %i[type id].freeze

describe JSONAPI::Exceptions::DocumentExceptions do

  # **********************************
  # USEFUL VARIABLES
  # **********************************

  include_context 'document exceptions'
  # response_doc is located in shared_context
  # dec as well ^

  # An example of a request document given by JSON:API spec
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

  # Alias for #check_compliance
  def f(document, is_a_request: nil, http_method_is_post: nil, sparse_fieldsets: false)
    JSONAPI::Exceptions::DocumentExceptions.check_compliance(
      document, is_a_request: is_a_request, http_method_is_post: http_method_is_post, sparse_fieldsets: sparse_fieldsets
    )
  end
  
  describe '#check_compliance' do
    
    # **********************************
    # * Check Essentials               *
    # **********************************

    context 'when checking essentials' do
      # **********************************
      # * BASELINE CHECKS                *
      # **********************************
      context 'when checking basic checks' do
  
        it 'should return nil if the document complies to all specs' do
          expect(f(response_doc)).to be nil      
          expect(f(req_doc, is_a_request: true)).to be nil      
          expect(f(req_doc, is_a_request: true, http_method_is_post: true)).to be nil  
        end
  
        it 'should raise when document is nil' do
          msg = 'A document cannot be nil'
          expect { f(nil, is_a_request: true) }.to raise_error(dec, msg)
          expect { f(nil) }.to raise_error(dec, msg)
        end
  
        it 'should raise if !request but http_method_is_post' do
          msg = 'A document cannot both belong to a post request and not belong to a request'
          expect { f(response_doc, is_a_request: false, http_method_is_post: true) }.to raise_error(dec, msg)
          expect(f(req_doc, http_method_is_post: true)).to be nil
        end
      end
  
      # **********************************
      # * CHECK TOP LEVEL                *
      # **********************************
      describe '#check_top_level' do
        it 'should raise if document is not a hash' do
          msg = 'A JSON object MUST be at the root of every JSON API request ' \
                'and response containing data'
          expect { f([], is_a_request: true) }.to raise_error(dec, msg)
          expect { f([]) }.to raise_error(dec, msg)
          expect { f(:asdj, is_a_request: true) }.to raise_error(dec, msg)
          expect { f(:asdj) }.to raise_error(dec, msg)
          expect { f(1234, is_a_request: true) }.to raise_error(dec, msg)
          expect { f(1234) }.to raise_error(dec, msg)
          expect { f('1234', is_a_request: true) }.to raise_error(dec, msg)
          expect { f('1234') }.to raise_error(dec, msg)
        end
          
        it 'should raise if a document does not contain at least one of the required keys' do
          msg = 'A document MUST contain at least one of the following ' \
                "top-level members: #{TOP_LEVEL_KEYS}"
          expect { f({ 'my_own_key': 'nothing' }) }.to raise_error(dec, msg)
          expect { f({ 'links': 'my_links' }) }.to raise_error(dec, msg)
        end
  
        it 'should return nil when document contains one of the top level keys' do
          expect(f({ 'errors': [] })).to be nil
        end
  
        it 'should raise if errors key present with data key' do
          msg = 'The members data and errors MUST NOT coexist in the same document'
          expect { f({ 'data': { 'type': 'author' }, 'errors': 'error' }) }.to raise_error(dec, msg)
        end
  
        it 'should raise if included key present without data key' do
          msg = 'If a document does not contain a top-level data key, the included ' \
                'member MUST NOT be present either'
          expect { f({ 'meta': { 'meta_info': 'm' }, 'included': 'incl_objs' }) }.to raise_error(dec, msg)
        end
  
        it 'should raise if no data member included and document is a request' do
          msg = 'The request MUST include a single resource object as primary data'
          expect { f({ 'meta': { 'meta_info': 'm' } }, is_a_request: true) }.to raise_error(dec, msg)
        end
      end
    end

    # **********************************
    # * CHECKING TOP LEVEL MEMBERS     *
    # **********************************
    describe '#check_members' do
      
      # -- TOP LEVEL - DATA:
      context 'when checking primary data' do
        it 'should raise if data not a hash when it is a request' do
          msg = 'The request MUST include a single resource object as primary data'
          expect { f({ meta: { 'count': 123 } }, is_a_request: true) }.to raise_error(dec, msg)
        end

        it 'should raise if not nil, a hash, or an array' do
          msg = 'Primary data must be either nil, an object or an array'
          expect { f({ data: 123 }) }.to raise_error(dec, msg)
          expect { f({ data: 'not_valid' }) }.to raise_error(dec, msg)
        end

        # -- TOP LEVEL - PRIMARY DATA * RESOURCE
        context 'when checking resource' do
          it 'should ignore any additional members' do
            expect(f({ data: { type: 't', id: '123', test: 'test' } })).to be nil
          end

          # -- TOP LEVEL - PRIMARY DATA * RESOURCE - Type & ID
          context 'when checking resource type and id' do
            it "should raise if it is not a post request and it doesn't have an id member" do
              msg = 'Every resource object MUST contain an id member and a type member'
              expect { f({ data: { type: 'type' } }) }.to raise_error(dec, msg)
            end

            it 'should return nil if id is not included, but it is a post request' do
              expect(f({ data: { type: 'type' } }, http_method_is_post: true)).to be nil
            end

            it 'should raise if type is ever not included' do
              msg_reg = 'Every resource object MUST contain an id member and a type member'
              expect { f({ data: {} }) }.to raise_error(dec, msg_reg)
              expect { f({ data: {} }, is_a_request: true) }.to raise_error(dec, msg_reg)
              msg_post = 'The resource object (for a post request) MUST contain at least a type member'
              expect { f({ data: {} }, http_method_is_post: true) }.to raise_error(dec, msg_post)
            end

            it 'should raise if the type of id or type is not string' do
              msg_id = 'The value of the resource id member MUST be string'
              expect { f({ data: { type: 't', id: 123 } }) }.to raise_error(dec, msg_id)
              msg_type = 'The value of the resource type member MUST be string'
              expect { f({ data: { type: 123, id: '123' } }) }.to raise_error(dec, msg_type)
            end

            it 'should raise if the resource fields do not share a common namespace' do
              msg = 'Fields for a resource object MUST share a common namespace with each ' \
                    'other and with type and id'
              expect do
                f(
                  { 
                    data: { 
                      type: 't', id: '123',
                      attributes: { not_unique: 'ex' },
                      relationships: { not_unique: { data: { type: 't', id: '123' } } }
                    }
                  }
                )
              end.to raise_error msg
              expect do
                f(
                  { 
                    data: { 
                      type: 't', id: '123',
                      attributes: { type: 'ex' },
                      relationships: { not_unique: { data: { type: 't', id: '123' } } }
                    }
                  }
                )
              end.to raise_error msg
              expect do
                f(
                  { 
                    data: { 
                      type: 't', id: '123',
                      attributes: { example: 'ex' },
                      relationships: { id: { data: { type: 't', id: '123' } } }
                    }
                  }
                )
              end.to raise_error msg
            end

            it 'should raise if the value of type does not conform to member naming rules' do
              msg = 'The values of type members MUST adhere to the same constraints as member names'
              expect { f({ data: { type: '***type***', id: '123' } }) }.to raise_error(dec, msg)
            end
          end

          # -- TOP LEVEL - PRIMARY DATA * RESOURCE - ATTRIBUTES
          context 'when checking attributes' do
            it 'should raise if attributes is not a hash' do
              msg = 'The value of the attributes key MUST be an object'
              expect { f({ data: { type: 't', id: '123', attributes: [] } }) }.to raise_error(dec, msg)
            end

            it 'should return nil if attributes is a hash' do
              expect(f({ data: { type: 't', id: '123', attributes: {} } })).to be nil
            end
          end

          # -- TOP LEVEL - PRIMARY DATA * RESOURCE - RELATIONSHIPS
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
              expect { f(rel_not_hash) }.to raise_error(dec, msg)
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
              msg = 'Each relationships member MUST be a object'
              expect { f(rel_key_not_hash) }.to raise_error(dec, msg)
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
              expect { f(rel_missing_keys) }.to raise_error(dec, msg)
            end

            # -- TOP LEVEL - PRIMARY DATA * RESOURCE - RELATIONSHIPS
            context 'checking each relationships member' do
              # TOP LEVEL - PRIMARY DATA * RESOURCE - RELATIONSHIPS * LINKS MEMBER
              context 'links relationship member' do
                it 'should raise it it does not have at least one of the required members' do
                  bad_rel1 =
                    {
                      data: {
                        type: 't',
                        id: '1',
                        relationships: {
                          author: {
                            links: { test: 'url' }
                          }
                        }
                      }
                    }
                  bad_rel2 =
                    {
                      data: {
                        type: 't',
                        id: '1',
                        relationships: {
                          author: {
                            links: {}
                          }
                        }
                      }
                    }
                  rel =
                    {
                      data: {
                        type: 't',
                        id: '1',
                        relationships: {
                          author: {
                            links: { self: 'url', related: { href: 'url' } }
                          }
                        }
                      }
                    }
                  msg = 'A relationship link MUST contain at least one of '\
                        "#{RELATIONSHIP_LINK_KEYS}"
                  expect { f(bad_rel1) }.to raise_error(dec, msg)
                  expect { f(bad_rel2) }.to raise_error(dec, msg)
                  expect(f(rel)).to be nil
                end

                it 'should raise standard check links errors and ignore additional members' do
                  rel_w_extra_member =
                    {
                      data: {
                        type: 't',
                        id: '1',
                        relationships: {
                          author: {
                            links: { extra_member: 'url', self: 'string' }
                          }
                        }
                      }
                    }
                  bad_rel_w_extra_member =
                    {
                      data: {
                        type: 't',
                        id: '1',
                        relationships: {
                          author: {
                            links: { extra_member: 'url', self: ['string'] }
                          }
                        }
                      }
                    }
                  expect(f(rel_w_extra_member)).to be nil
                  msg = 'A link MUST be represented as either a string or an object'
                  expect { f(bad_rel_w_extra_member) }.to raise_error(dec, msg)
                end
              end

              # -- TOP LEVEL - PRIMARY DATA * RESOURCE - RELATIONSHIPS * DATA
              context 'checking data' do
                it 'should raise if data is not a hash array or nil' do
                  msg = 'Resource linkage (relationship data) MUST be either nil, an object or an array'
                  expect { f({ data: { type: 't', id: '1', relationships: { author: { data: 'test' } } } }) }.to raise_error(dec, msg)
                end

                # -- TOP LEVEL - PRIMARY DATA * RESOURCE - RELATIONSHIPS * DATA - RESOURCE IDs
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
                    msg = 'A resource identifier object MUST be an object'
                    expect { f(rel_id_not_hash) }.to raise_error(dec, msg)
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
                    msg = 'A resource identifier object MUST contain ' \
                          "#{RESOURCE_IDENTIFIER_KEYS} members"
                    expect { f(rel_no_id) }.to raise_error(dec, msg)
                    expect { f(rel_no_type) }.to raise_error(dec, msg)
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
                    msg_id = 'The resource identifier id member must be a string'
                    msg_type = 'The resource identifier type member must be a string'
                    expect { f(rel_id_not_string) }.to raise_error(dec, msg_id)
                    expect { f(rel_type_not_string) }.to raise_error(dec, msg_type)
                  end

                  it 'should return nil if given a valid meta object' do
                    rel =
                      {
                        data: {
                          type: 't', id: '1', relationships: { author: { meta: { count: '1' } } }
                        }
                      }
                    expect(f(rel)).to be nil
                  end

                  it 'should raise if the given meta member is not a hash' do
                    rel =
                      {
                        data: {
                          type: 't', id: '1', relationships: { author: { meta: ['meta_not_hash'] } }
                        }
                      }
                    msg = 'A meta object MUST be an object'
                    expect { f(rel) }.to raise_error(dec, msg)
                  end
                end
              end

              # -- TOP LEVEL - PRIMARY DATA * RESOURCE - RELATIONSHIPS * META MEMBER
              context 'checking meta member' do
                it 'should raise if meta member is not a hash' do
                  rel_meta_not_hash =
                    {
                      data: {
                        type: 't',
                        id: '123',
                        relationships: {
                          author: {
                            meta: []
                          }
                        }
                      }
                    }
                  msg = 'A meta object MUST be an object'
                  expect { f(rel_meta_not_hash) }.to raise_error(dec, msg)
                end
              end
            end
          end

          # TOP LEVEL - PRIMARY DATA * RESOURCE - LINKS MEMBER
          context 'checking resource links' do
            it 'should raise if resource links not a hash' do
              res = 
                {
                  data: {
                    type: 't', id: '1', links: ['links']
                  }
                }
              msg = 'A links object MUST be an object'
              expect { f(res) }.to raise_error(dec, msg)
            end
            
            it 'should raise if resource links members not a string or hash' do
              res = 
                {
                  data: {
                    type: 't', id: '1', links: { self: ['string'] }
                  }
                }
              msg = 'A link MUST be represented as either a string or an object'
              expect { f(res) }.to raise_error(dec, msg)
            end
          end

          # -- TOP LEVEL - PRIMARY DATA * RESOURCE - META MEMBER
          context 'checking resource meta' do
            it 'should raise if resource meta not a hash' do
              res = 
                {
                  data: {
                    type: 't', id: '1', meta: ['meta']
                  }
                }
              msg = 'A meta object MUST be an object'
              expect { f(res) }.to raise_error(dec, msg)
            end
          end
        end
      end

      #  -- TOP LEVEL - ERRORS:
      context 'when checking top level errors' do
        it 'should return nil if given valid input' do
          err =
            {
              errors: [
                {
                  status: '422',
                  'source': { 'pointer': '/data/attributes/firstName' },
                  'title': 'Invalid Attribute',
                  'detail': 'First name must contain at least three characters.'
                }
              ]
            }
          expect(f(err)).to be nil
        end

        it 'should raise if errors not an array' do
          err = {
            errors: {}
          }
          msg = 'Top level errors member MUST be an array'
          expect { f(err) }.to raise_error(dec, msg)
        end

        it 'should raise if any of the errors array values are not hashes' do
          err = {
            errors: [
              { id: '123' },
              ['string', 'test']
            ]
          }
          msg = 'Error objects MUST be objects'
          expect { f(err) }.to raise_error(dec, msg)
        end
      end

      # -- TOP LEVEL - META:
      context 'when checking top level meta' do
        it 'should return nil if top level meta is a hash' do
          m = {
            meta: {}
          }
          expect(f(m)).to be nil
        end
        
        it 'should raise if top level meta is not a hash' do
          m = {
            meta: []
          }
          msg = 'A meta object MUST be an object'
          expect { f(m) }.to raise_error(dec, msg)
        end
      end

      # -- TOP LEVEL - JSONAPI:
      context 'when checking top level jsonapi' do
        it 'should be a hash' do
          j_not_hash = {
            data: { type: 't', id: '1' },
            jsonapi: []
          }
          msg = 'A JSONAPI object MUST be an object'
          expect { f(j_not_hash) }.to raise_error(dec, msg)
        end

        it 'should raise if it has version and the value of version is not string' do
          j_v_not_str = {
            data: { type: 't', id: '1' },
            jsonapi: { version: [] }
          }
          msg = "The value of JSONAPI's version member MUST be a string"
          expect { f(j_v_not_str) }.to raise_error(dec, msg)
        end

        it 'should raise if an error with an included meta obj' do
          j_w_bad_m = {
            data: { type: 't', id: '1' },
            jsonapi: { meta: [] }
          }
          msg = 'A meta object MUST be an object'
          expect { f(j_w_bad_m) }.to raise_error(dec, msg)
        end

        it 'should return nil if given valid input, ignoring extra members if there are any' do
          j = {
            data: { type: 't', id: '1' },
            jsonapi: { version: '1.0', meta: { count: '1' }, extra_member: 'member' }
          }
          expect(f(j)).to be nil
        end
      end
      
      # -- TOP LEVEL - LINKS:
      context 'when checking top level links' do
        it 'should return nil if given proper input' do
          l = {
            data: { type: 't', id: '1' },
            links: {
              self: 'url',
              related: { href: 'url', meta: { count: '1' } },
              prev: 'ur',
              next: 'url',
              first: 'url',
              last: 'url'
            }
          }
          expect(f(l)).to be nil
        end
        
        it 'should be a hash' do
          msg = 'A links object MUST be an object'
          expect { f({ data: { type: 't', id: '1' }, links: [] }) }.to raise_error(dec, msg)
        end

        it 'should ignore additional top level links members' do
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
          expect(f({ data: { type: 'type', id: '123' }, links: links_obj_w_added_member })).to be nil
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
          msg_href = 'The member href MUST be a string'
          msg_meta = 'The value of each meta member MUST be an object'
          expect { f({ data: { type: 'type', id: '123' }, links: bad_links_href }) }.to raise_error(dec, msg_href)
          expect { f({ data: { type: 'type', id: '123' }, links: bad_links_meta }) }.to raise_error(dec, msg_meta)
          expect(f({ data: { type: 'type', id: '123' }, links: good_links })).to be nil
        end
      end

      # -- TOP LEVEL - INCLUDED:
      context 'when checking top level included' do
        it 'should be a array' do
          i_not_arr = {
            data: { type: 't', id: '1', relationships: { author: { data: { type: 't', id: '2' } } } },
            included: { type: 't', id: '2' }
          }
          msg = 'The top level included member MUST be represented as an array of resource objects'
          expect { f(i_not_arr) }.to raise_error(dec, msg)

          i = {
            data: { type: 't', id: '1', relationships: { author: { data: { type: 't', id: '2' } } } },
            included: [{ type: 't', id: '2' }]
          }
          expect(f(i)).to be nil
        end

        it 'should raise if a resource error is found' do
          i_id_not_str = {
            data: { type: 't', id: 1, relationships: { author: { data: { type: 't', id: '2' } } } },
            included: [{ type: 't', id: '2' }]
          }
          msg = 'The value of the resource id member MUST be string'
          expect { f(i_id_not_str) }.to raise_error(dec, msg)
        end
      end

      # -- Checking Full Linkage:
      context 'when checking full linkage of includes' do
        fully_linked_doc = {
          "data": [{
            "type": "articles",
            "id": "1",
            "relationships": {
              "author": {
                "data": { "type": "people", "id": "9" }
              },
              "comments": {
                "data": [
                  { "type": "comments", "id": "5" },
                  { "type": "comments", "id": "12" }
                ]
              }
            }
          }],
          "included": [
            {
              "type": "people",
              "id": "9"
            }, 
            {
              "type": "comments",
              "id": "5",
              "relationships": {
                "author": {
                  "data": { "type": "people", "id": "2" }
                }
              }
            }, 
            {
              "type": "comments",
              "id": "12",
              "relationships": {
                "author": {
                  "data": { "type": "people", "id": "9" }
                }
              }
            }
          ]
        }
        
        it 'should return nil when a document is fully linked' do
          expect(f(fully_linked_doc)).to eq nil
        end
        
        it 'should raise if any included resource does not have a corresponding res_id' do
          not_fully_linked_doc1 = {}
          not_fully_linked_doc2 = {}
          not_fully_linked_doc1.replace fully_linked_doc
          not_fully_linked_doc2.replace fully_linked_doc
          
          not_fully_linked_doc1[:data][0][:relationships][:comments][:data][0][:id] = 'not_linked'
          
          not_fully_linked_doc2[:data][0][:relationships][:author][:data][:id] = '10'
          not_fully_linked_doc2[:included][2][:relationships][:author][:data][:id] = '10'
          
          msg = 'Compound documents require “full linkage”, meaning that every included resource MUST be ' \
                'identified by at least one resource identifier object in the same document.'
          
          expect { f(not_fully_linked_doc1) }.to raise_error(dec, msg)
          expect { f(not_fully_linked_doc2) }.to raise_error(dec, msg)
        end

        it 'should return nil if not fully linked, but sparse fieldsets are included' do
          not_fully_linked_doc1 = {}
          not_fully_linked_doc2 = {}
          not_fully_linked_doc1.replace fully_linked_doc
          not_fully_linked_doc2.replace fully_linked_doc
          
          not_fully_linked_doc1[:data][0][:relationships][:comments][:data][0][:id] = 'not_linked'
          
          not_fully_linked_doc2[:data][0][:relationships][:author][:data][:id] = '10'
          not_fully_linked_doc2[:included][2][:relationships][:author][:data][:id] = '10'

          expect(f(not_fully_linked_doc1, sparse_fieldsets: true)).to be nil
          expect(f(not_fully_linked_doc2, sparse_fieldsets: true)).to be nil
        end
      end
    end
    
    # **********************************
    # * CHECKING MEMBER NAMES          *
    # **********************************
    describe 'check_member_names' do

      it 'should raise when given empty keys (no characters)' do
        doc_w_empty_keys = 
          {
            data: { type: 't', id: '1', attributes: { '': 'empty key' } }
          }
        msg = "The member named '' raised: Member names MUST contain at least one character"
        expect { f(doc_w_empty_keys) }.to raise_error(dec, msg)
      end

      it 'should raise when a member name containing any prohibitted letters' do
        name_w_bad_letters1 = 
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

        name_w_bad_letters2 = 
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
  
        name_w_bad_letters3 = 
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

        msg = "The member named '***title***' raised: Member names MUST contain only the allowed " \
              "characters: a-z, A-Z, 0-9, '-', '_'"
        expect { f(name_w_bad_letters1) }.to raise_error(dec, msg)
        msg = "The member named '***author***' raised: Member names MUST contain only the allowed " \
              "characters: a-z, A-Z, 0-9, '-', '_'"
        expect { f(name_w_bad_letters2) }.to raise_error(dec, msg)
        msg = "The member named '***comments***' raised: Member names MUST contain only the allowed " \
              "characters: a-z, A-Z, 0-9, '-', '_'"
        expect { f(name_w_bad_letters3) }.to raise_error(dec, msg)
      end

      it 'should return nil given a correct document' do
        expect(f(response_doc)).to be nil
      end
    end

  end
end
