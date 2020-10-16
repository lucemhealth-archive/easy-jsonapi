# frozen_string_literal: true

require 'rack/jsonapi/exceptions/document_exceptions'

TOP_LEVEL_KEYS = %w[data errors meta jsonapi links included].freeze
LINKS_KEYS = %w[self related first prev next last].freeze

RESOURCE_KEYS = %w[type id attributes relationships links meta].freeze
RESOURCE_IDENTIFIER_KEYS = %w[id type].freeze
RELATIONSHIP_KEYS = 'data links meta'
RELATIONSHIP_LINK_KEYS = %w[self related].freeze
JSONAPI_OBJECT_KEYS = %w[version meta].freeze
ERROR_KEYS = %w[id links status code title detail source meta].freeze

describe JSONAPI::Exceptions::DocumentExceptions do

  let(:error_class) { JSONAPI::Exceptions::DocumentExceptions::InvalidDocument }

  let(:doc) do
    {
      'data' => 
        {
          'type' => 'articles',
          'id' => '1',
          'attributes' => { 'title' => 'JSON API paints my bikeshed!' },
          'links' => { 'self' => 'http://example.com/articles/1' },
          'relationships' => {
            'author' => {
              'links' => {
                'self' => 'http://example.com/articles/1/relationships/author',
                'related' => 'http://example.com/articles/1/author'
              },
              'data' => { 'type' => 'people', 'id' => '9' }
            },
            'journal' => {
              'data' => nil
            },
            'comments' => {
              'links' => {
                'self' => 'http://example.com/articles/1/relationships/comments',
                'related' => 'http://example.com/articles/1/comments'
              },
              'data' => [
                { 'type' => 'comments', 'id' => '5' },
                { 'type' => 'comments', 'id' => '12' }
              ]
            }
          }
        },
      'meta' => { 'count' => '13' }
    }
  end

  # let(:bad_name_doc) do
  #   {
  #     'data' => 
  #       {
  #         'type' => 'articles',
  #         'id' => '1',
  #         'attributes' => { 'BAD NAME!!??@@!' => 'JSON API paints my bikeshed!' },
  #         'links' => { 'self' => 'http://example.com/articles/1' },
  #         'relationships' => {
  #           'author' => {
  #             'links' => {
  #               'self' => 'http://example.com/articles/1/relationships/author',
  #               'related' => 'http://example.com/articles/1/author'
  #             },
  #             'data' => { 'type' => 'people', 'id' => '9' }
  #           }
  #         }
  #       },
  #     'meta' => { 'count' => '13' }
  #   }
  # end

  describe '#check_compliance!' do

    def f(doc, is_a_request, is_a_post_request)
      JSONAPI::Exceptions::DocumentExceptions.check_compliance!(doc, is_a_request, is_a_post_request)
    end

    it 'should raise a runtime error if !is_a_request but is_a_post_request' do
      expect { f(nil, false, true) }.to raise_error 'Cannot be a post request and not a request'
    end

    it 'should return nil if the document complies to all specs' do
      expect(f(doc, false, false)).to be nil      
      expect(f(doc, true, false)).to be nil      
      expect(f(doc, true, true)).to be nil  
    end

    # it 'should raise a InvalidDocument error if any of the document member names do not comply' do
    #   expect { f(bad_name_doc, false, false) }.to raise_error(error_class, msg)
    # end

    describe '#check_top_level' do
      context 'when document does not contain one of the top level keys' do
        msg = 'A document MUST contain at least one of the following ' \
              "top-level members: #{TOP_LEVEL_KEYS}"
        
        it 'should raise InvalidDocument when document is nil' do
          expect { f(nil, true, false) }.to raise_error(error_class, msg)
          expect { f(nil, false, false) }.to raise_error(error_class, msg)
        end

        it 'should raise InvalidDocument when document contains other keys' do
          expect { f({ 'my_own_key' => 'nothing' }, false, false) }.to raise_error(error_class, msg)
          expect { f({'links' => 'my_links' }, false, false) }.to raise_error(error_class, msg)
        end
      end

      it 'should return nil when document contains one of the top level keys' do
        expect(f({ 'errors' => { 'err1' => '1' } }, false, false)).to be nil
      end

    
      context 'when document is not a hash' do
        it 'should raise an error' do
          msg = 'A JSON object MUST be at the root of every JSON API request ' \
                'and response containing data.'
          expect { f([], true, false) }.to raise_error(error_class, msg)
          expect { f([], false, false) }.to raise_error(error_class, msg)
          expect { f(:asdj, true, false) }.to raise_error(error_class, msg)
          expect { f(:asdj, false, false) }.to raise_error(error_class, msg)
          expect { f(1234, true, false) }.to raise_error(error_class, msg)
          expect { f(1234, false, false) }.to raise_error(error_class, msg)
          expect { f('1234', true, false) }.to raise_error(error_class, msg)
          expect { f('1234', false, false) }.to raise_error(error_class, msg)
        end
      end

      context 'when document contains data member' do
        it 'should raise InvalidDocument if errors key present with data key' do
          msg = 'The members data and errors MUST NOT coexist in the same document.'
          expect { f({ 'data' => { 'type' => 'author' }, 'errors' => 'error' }, false, false) }.to raise_error(error_class, msg)
        end
      end

      context 'when document does not contain data member' do
        it 'should raise InvalidDocument if included key present without data key' do
          msg = 'If a document does not contain a top-level data key, the included ' \
                'member MUST NOT be present either.'
          expect { f({ 'meta' => { 'meta_info' => 'm' }, 'included' => 'incl_objs' }, false, false) }.to raise_error(error_class, msg)
        end

        context 'when document belongs to a request' do
          it 'should raise InvalidDocument if no data member included' do
            msg = 'The request MUST include a single resource object as primary data.'
            expect { f({ 'meta' => { 'meta_info' => 'm' } }, true, false) }.to raise_error(error_class, msg)
          end
        end
      end
    end
    
  #   context 'when testing the data key for errors' do
  #     it 'should return nil if data is not present in a non_request document' do
  #       expect(f({ 'meta' => { 'meta_info' => 'm' } }, false, false)).to be nil
  #     end

  #     context 'is_a_request is true' do
  #       it 'should raise InvalidDocument if data is an array' do
  #         expect { f({ 'data' => ['test', 'ing'] }, true, false) }.to raise_error(error_class, msg)
  #       end
  #     end
      
  #     context 'data is neither an array, nor a hash, nor nil' do
  #       it 'should raise InvalidDocument' do
  #         expect { f({ 'data' => 'test' }, false, false) }.to raise_error(error_class, msg)
  #         expect { f({ 'data' => 'test' }, true, false) }.to raise_error(error_class, msg)
  #       end
  #     end
  #   end

  #   context 'when checking resource objects for errors' do
  #     context 'when not a post request' do
  #       it 'should raise InvalidDocument if id or type is missing' do
  #         expect { f({ 'data' => { 'not_id' => '1', 'not_type' => 'test' } }, true, false) }.to raise_error(error_class, msg)
  #         expect { f({ 'data' => { 'not_id' => '1', 'type' => 'test' } }, true, false) }.to raise_error(error_class, msg)
  #         expect { f({ 'data' => { 'id' => '1', 'not_type' => 'test' } }, true, false) }.to raise_error(error_class, msg)
  #       end
  #     end
      
  #     context 'when a post request' do
  #       it 'should raise InvalidDocument if type is missing' do
  #         expect { f({ 'data' => { 'not_type' => 'test' } }, true, true) }.to raise_error(error_class, msg)
  #       end
  #     end

  #     context 'when testing type and id values' do
  #       it 'should raise InvalidDocument if id is present and the type of the value is not string' do
  #         expect { f({ 'data' => { 'type' => 'test', 'id' => 123 } }, true, true) }.to raise_error(error_class, msg)
  #         expect { f({ 'data' => { 'type' => 'test', 'id' => 123 } }, true, false) }.to raise_error(error_class, msg)
  #         expect { f({ 'data' => { 'type' => 'test', 'id' => 123 } }, false, false) }.to raise_error(error_class, msg)
  #       end
        
  #       it 'should raise InvalidDocument if the value of type is not string' do
  #         expect { f({ 'data' => { 'type' => 123 } }, false, false) }.to raise_error(error_class, msg)
  #         expect { f({ 'data' => { 'type' => 123 } }, true, false) }.to raise_error(error_class, msg)
  #         expect { f({ 'data' => { 'type' => 123 } }, true, true) }.to raise_error(error_class, msg)
  #       end
        
  #       it 'should return nil if type and id are present when necessary and are of type string' do
  #         expect(f({ 'data' => { 'type' => 'test', 'id' => '1' } }, false, false)).to be nil
  #         expect(f({ 'data' => { 'type' => 'test', 'id' => '1' } }, true, false)).to be nil
  #         expect(f({ 'data' => { 'type' => 'test', 'id' => '1' } }, true, true)).to be nil
  #         expect(f({ 'data' => { 'type' => 'test' } }, true, true)).to be nil
  #       end
  #     end

  #     context 'when testing data keys' do
        
  #       let(:good_data) do
  #         {
  #           'data' =>
  #             {
  #               'type' => 'test',
  #               'id' => '1',
  #               'attributes' => { 'name' => 'a' },
  #               'relationships' => { 'rel' => { 'r' => 'el' } },
  #               'meta' => { 'met' => 'm' },
  #               'links' => { 'link' => 'l' }
  #             }
  #         }
  #       end
      
  #       let(:bad_data) do
  #         {
  #           'data' =>
  #             {
  #               'type' => 'test',
  #               'id' => '1',
  #               'attributes' => 'a',
  #               'relationships' => 'r',
  #               'meta' => 'm',
  #               'links' => 'l',
  #               'extra_member' => 'error'
  #             }
  #         }
  #       end
        
  #       it 'should raise InvalidDocument if non resource members are present' do
  #         expect { f(bad_data, false, false) }.to raise_error(error_class, msg)
  #       end

  #       it 'should return nil when only resource members are present' do
  #         expect(f(good_data, false, false)).to be nil
  #       end
  #     end

  #     context 'when testing attributes' do
  #       it 'should raise InvalidDocument if attributes is not a hash' do
  #         expect { f({ 'data' => { 'type' => 't', 'id' => '1', 'attributes' => 'name' } }, false, false) }.to raise_error(error_class, msg)
  #       end

  #       it 'should return nil if formatted correctly' do
  #         expect(f({ 'data' => { 'type' => 't', 'id' => '1', 'attributes' => { 'name' => 'test' } } }, false, false)).to be nil
  #       end
  #     end
  #   end
  end



  # ****************************************
  # TESTING PRIVATE CLASS METHODS -- NEED TO COMMENT OUT PRIVATE DECLARATION IN document_exceptions.rb


  # describe '#check_member_names!' do
    
  #   it 'should raise InvalidDocument with the appropriate message when a bad member name exists' do
  #     expect { JSONAPI::Exceptions::DocumentExceptions.check_member_names!(bad_name_doc) }.to raise_error(error_class, msg)
  #   end

  #   it 'should return nil given a correct document' do
  #     expect(JSONAPI::Exceptions::DocumentExceptions.check_member_names!(doc)).to be nil
  #   end

  # end
  
  # ************************************






  # it 'succeeds on nil data' do
  #   payload = { 'data' => nil }

  #   expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  # end

  # it 'succeeds on empty array data' do
  #   payload = { 'data' => [] }

  #   expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  # end

  # it 'works' do
  #   payload = 

  #   expect { JSONAPI.parse_response!(payload) }.not_to raise_error
  # end

  # it 'passes regardless of id/type order' do
  #   payload = {
  #     'data' => [
  #       {
  #         'type' => 'articles',
  #         'id' => '1',
  #         'relationships' => {
  #           'comments' => {
  #             'data' => [
  #               { 'type' => 'comments', 'id' => '5' },
  #               { 'id' => '12', 'type' => 'comments' }
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
  #     'data' => [
  #       {
  #         'type' => 'articles',
  #         'id' => '1',
  #         'relationships' => {
  #           'author' => {
  #             'data' => { 'type' => 'people' }
  #           }
  #         }
  #       }
  #     ]
  #   }

  #   expect { JSONAPI.parse_response!(payload) }.to raise_error(
  #     JSONAPI::Parser::InvalidDocument,
  #     'A resource identifier object MUST contain ["id", "type"] members.'
  #   )
  # end
  
end
