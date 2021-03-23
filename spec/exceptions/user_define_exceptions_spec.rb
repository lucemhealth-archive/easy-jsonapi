# frozen_string_literal: true

require 'rack/jsonapi/exceptions/user_defined_exceptions'
require 'rack/jsonapi/config_manager'
require 'rack/jsonapi/config_manager/config'

describe JSONAPI::Exceptions::UserDefinedExceptions do
  let(:cm) { JSONAPI::ConfigManager.new }

  let(:c) { JSONAPI::ConfigManager::Config.new }
  
  describe '#check_user_document_requirements' do

    let(:err) { JSONAPI::Exceptions::DocumentExceptions::InvalidDocument }

    let(:doc1) do
      {
        data: {
          type: 'person',
          attributes: {
            a1: 'a1',
            a2: 'a2'
          }
        }
      }
    end

    let(:doc_bad_arr) do
      {
        data: [
          {
            type: 'testing',
            attributes: {
              a1: 'a1',
              a2: 'a2'
            }
          },
          {
            type: 'testing2'

          },
          {
            type: 'testing3'
          }
        ]
      }
    end

    let(:doc_good_arr) do
      {
        data: [
          {
            type: 'testing',
            attributes: {
              a1: 'a1',
              a2: 'a2'
            }
          },
          {
            type: 'testing2',
            attributes: {
              a1: 'a1',
              a2: 'a2'
            }
          },
          {
            type: 'testing3',
            attributes: {
              a1: 'a1',
              a2: 'A-2'
            }
          }
        ]
      }
    end

    let(:req_check_top_level) do
      {
        data: {
          type: nil,
          attributes: nil
        },
        meta: nil
      }
    end

    let(:req_check_lower_level) do
      {
        data: {
          type: nil,
          attributes: { a3: nil }
        }
      }
    end

    let(:req_mic_doc1) do
      {
        data: {
          type: nil,
          attributes: nil
        }
      }
    end

    let(:req_arr) do
      {
        data: [
          {
            type: nil,
            attributes: {
              a1: nil, a2: nil
            }
          }
        ]
      }
    end

    let(:req_w_values) do
      {
        data: { type: proc { |v| %w[person place thing].include?(v) } }
      }
    end

    let(:req_arr_w_values1) do
      {
        data: [{ type: proc { |v| %w[person place thing].include?(v) } }]
      }
    end

    let(:req_arr_w_values2) do
      {
        data: [{ type: nil, attributes: { a1: proc { |v| %w[a2 a3].include?(v) } } }]
      }
    end

    let(:req_arr_w_values3) do
      {
        data: [{ type: nil, attributes: { a1: proc { |v| %w[a1 a2 A-2 a3].include?(v) } } }]
      }
    end
    
    def check(document, config_manager, http_method = "GET", path = '/res_name')
      JSONAPI::Exceptions::UserDefinedExceptions.check_user_document_requirements(document, config_manager, { path: path, http_method: http_method })
    end

    context 'when checking if per_resource checks work' do
      it 'should return an error msg when a top-level, user-defined, required member is not included' do
        cm[:res_name] = c
        cm[:res_name].required_document_members = req_check_top_level
        expect(check(doc1, cm).msg).to eq "Document is missing user-defined required keys: [:meta]"
        expect(check(doc1, cm).status_code).to eq 400
        expect(check(doc1, cm).class).to eq JSONAPI::Exceptions::UserDefinedExceptions::InvalidDocument
      end
    end

    # FIXME: Provide per model checking
    describe 'check_additional_required_members' do
      it 'should return an error msg when a top-level, user-defined, required member is not included' do
        cm.global.required_document_members = req_check_top_level
        expect(check(doc1, cm).msg).to eq "Document is missing user-defined required keys: [:meta]"
        expect(check(doc1, cm).status_code).to eq 400
        expect(check(doc1, cm).class).to eq JSONAPI::Exceptions::UserDefinedExceptions::InvalidDocument
      end

      it 'should return an error msg when a lower-level, user-defined, required member is not included' do
        cm.global.required_document_members = req_check_lower_level
        expect(check(doc1, cm).msg).to eq "Document is missing user-defined required keys: [:a3]"
      end

      it 'should pass if all the required keys are included' do
        cm.global.required_document_members = req_mic_doc1
        expect(check(doc1, cm)).to be nil
      end

      it 'should check each obj in the document array to make sure it includes the required memebers' do
        cm.global.required_document_members = req_arr
        expect(check(doc_bad_arr, cm).msg).to eq "Document is missing user-defined required keys: [:attributes]"
        expect(check(doc_good_arr, cm)).to be nil
      end

      it 'should check given document value to see if it is included in the given permitted req_mems array' do
        cm.global.required_document_members = req_w_values
        expect(check(doc1, cm)).to be nil

        cm.global.required_document_members = req_arr_w_values1
        expect(check(doc_good_arr, cm).msg.match(/The user-defined Proc found at/).class).to eq MatchData
        
        cm.global.required_document_members = req_arr_w_values2
        expect(check(doc_good_arr, cm).msg.match(/The user-defined Proc found at/).class).to eq MatchData

        cm.global.required_document_members = req_arr_w_values3
        expect(check(doc_good_arr, cm)).to be nil
      end
    end

    # FIXME: Provide per model checking
    describe 'check for client generated ids' do
      it 'should return an error messsage when an id is included when not allowed' do
        doc_w_id = {}
        doc_w_id.replace(doc1)
        doc_w_id[:data][:id] = 'should_not_be_included'
        msg = 'Document MUST return 403 Forbidden in response to an unsupported request ' \
              'to create a resource with a client-generated ID.'
        expect(check(doc_w_id, cm, 'POST').msg).to eq msg
        expect(check(doc_w_id, cm, 'POST').status_code).to eq 403
      end

      it 'should return nil when an id given OR not given when allowed' do
        expect(check(doc1, cm)).to be nil
        cm.global.allow_client_ids = true
        doc_w_id = {}
        doc_w_id.replace(doc1)
        doc_w_id[:data][:id] = 'can_be_included'
        expect(check(doc_w_id, cm, 'POST')).to be nil
      end
    end

  end

  describe '#check_user_header_requirements' do

    let(:included_headers) do
      {
        'CONTENT_TYPE' => 'idk',
        'ACCEPT' => '*/*',
        'CONTENT_LENGTH' => '123'
      }
    end

    def check(included_headers, config_manager, http_method = 'POST', path = '/res_type')
      JSONAPI::Exceptions::UserDefinedExceptions.check_user_header_requirements(included_headers, config_manager, { http_method: http_method, path: path })
    end

    describe '#check_for_required_headers' do
      it 'should return an error msg when a required header is absent' do
        cm.global.required_headers = %w[content-type xxx-authentication]
        expect(check(included_headers, cm).msg).to eq 'Headers missing one of the user-defined required headers: XXX_AUTHENTICATION'
        expect(check(included_headers, cm).status_code).to eq 400
        expect(check(included_headers, cm).class).to eq JSONAPI::Exceptions::UserDefinedExceptions::InvalidHeader
      end

      it 'should return nil when all required headers are present' do
        cm.global.required_headers = %w[content-type accept]
        expect(check(included_headers, cm)).to be nil
      end
    end
  end

  describe '#check_user_query_param_requirements' do
    let(:included_params) do
      {
        'fields' => { 'articles' => 'title,body,author', 'people' => 'name' },
        'include' => 'author,comments-likers,comments.users',
        'josh_ua' => 'demoss,simpson',
        'page' => { 'offset' => '5', 'limit' => '20' },
        'filter' => { 'comments' => '(author/age > 21)', 'users' => '(age < 15)' },
        'sort' => 'age,title'
      }
    end

    # TODO: Per resource
    # TODO: Provide cm option for max include depth -- think DOS attack
    # TODO: Provide cm option for puting limit on page[limit]
    #   per resource and global (undefined defaults out the box)
    let(:required_params1) do
      {
        fields: { articles: nil },
        include: nil,
        joseph: nil
      } 
    end

    let(:required_params2) do
      {
        fields: 'this is not allowed'
      }
    end
      
    let(:required_params3) do
      {
        fields: { articles: nil },
        include: nil,
        page: nil
      } 
    end

    def check(included_params, config_manager, http_method = 'POST', path = '/res_name')
      JSONAPI::Exceptions::UserDefinedExceptions.check_user_query_param_requirements(included_params, config_manager, { http_method: http_method, path: path })
    end

    it 'should return an error msg when a required param is absent' do
      cm.global.required_query_params = required_params1
      expect(check(included_params, cm).msg).to eq 'Query Params missing one of the user-defined required query params: joseph'
      expect(check(included_params, cm).status_code).to eq 400
      expect(check(included_params, cm).class).to eq JSONAPI::Exceptions::UserDefinedExceptions::InvalidQueryParam
    end

    it 'should return an error msg when the user-defined required params hash contains a value other than hash or nil' do
      cm.global.required_query_params = required_params2
      expect(check(included_params, cm).msg).to eq 'The user-defined required query params hash must contain keys with values either hash or nil'
    end

    it 'should return nil when all required params are present' do
      cm.global.required_query_params = required_params3
      expect(check(included_params, cm)).to be nil
    end
  end
end
