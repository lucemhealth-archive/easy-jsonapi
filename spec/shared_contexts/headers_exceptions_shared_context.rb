# frozen_string_literal: true

shared_context 'headers exceptions' do
  
  let(:hec) { JSONAPI::Exceptions::HeadersExceptions::InvalidHeader }
  
  # Should pass
  let(:env1) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # Should raise bc neither jsonapi
  let(:env2) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'text/plain'
    }
  end

  # Should raise bc accept hdr not jsonapi
  let(:env3) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end
  
  # Should raise bc content-type hdr not jsonapi
  let(:env4) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json',
      'CONTENT_TYPE' => 'text/plain'
    }
  end

  # Should raise error bc of content type
  let(:env5) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'application/vnd.api+json; idk'
    }
  end

  # Should raise error because of HTTP_ACCEPT
  let(:env6) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json ; q=0.5, text/*, image/* ; q=.3',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # Should raise error because of both
  let(:env7) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json ; q=0.5, text/*, image/* ; q=.3',
      'CONTENT_TYPE' => 'application/vnd.api+json ; idk'
    }
  end

  # ENVs WITH HTTP VERB and BODY INCLUDED ------------------------------------

  # GET ------------

  # GET - accept, but w body
  # Should raise bc of body
  let(:get_w_body) do
    {
      'REQUEST_METHOD' => 'GET',
      'HTTP_ACCEPT' => 'application/vnd.api+json, text/*',
      'rack.input' => StringIO.new('I have a body')
    }
  end

  # GET - no body, no accept or content-type headers
  # SHOULD PASS
  let(:get_no_hdrs) do
    {
      'REQUEST_METHOD' => 'GET'
    }
  end

  # GET - no accept, but has content-type
  # SHOULD RAISE bc contains content-type header
  let(:get_w_content_type1) do
    {
      'REQUEST_METHOD' => 'GET',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # GET - accept jsonapi, but has content-type
  # SHOULD RAISE bc contains content-type header
  let(:get_w_content_type2) do
    {
      'REQUEST_METHOD' => 'GET',
      'HTTP_ACCEPT' => 'application/vnd.api+json, text/*',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # POST, PATCH, and PUT -------------

  # POST - no body
  # SHOULD RAISE bc needs a body
  let(:post_no_body) do
    {
      'REQUEST_METHOD' => 'POST'
    }
  end

  # POST - no content-type header
  # SHOULD RAISE
  let(:post_no_content_type) do
    {
      'REQUEST_METHOD' => 'POST',
      'rack.input' => StringIO.new('Body')
    }
  end

  # POST - accept header not jsonapi
  # SHOULD RAISE even though middleware wouldn't check for compliance.
  let(:post_accept_not_jsonapi) do
    {
      'REQUEST_METHOD' => 'POST',
      'CONTENT_TYPE' => 'application/vnd.api+json',
      'HTTP_ACCEPT' => 'text/*',
      'rack.input' => StringIO.new('Body')
    }
  end

  # POST content type not jsonapi
  # SHOULD RAISE even though middleware wouldn't check for compliance.
  let(:post_content_type_not_jsonapi) do
    {
      'REQUEST_METHOD' => 'POST',
      'CONTENT_TYPE' => 'text/html',
      'rack.input' => StringIO.new('Body')
    }
  end
  
  # POST content-type and accept header jsonapi
  # SHOULD PASS
  let(:post_content_type_and_accept_jsonapi) do
    {
      'REQUEST_METHOD' => 'POST',
      'CONTENT_TYPE' => 'application/vnd.api+json',
      'HTTP_ACCEPT' => 'application/vnd.api+json',
      'rack.input' => StringIO.new('Body')
    }
  end
  
  # POST content-type and accept header jsonapi
  # SHOULD RAISE even though the middleware wouldn't check for compliance
  let(:post_content_type_jsonapi_but_accept_not_jsonapi) do
    {
      'REQUEST_METHOD' => 'POST',
      'CONTENT_TYPE' => 'application/vnd.api+json',
      'HTTP_ACCEPT' => 'text/*',
      'rack.input' => StringIO.new('Body')
    }
  end

  # DELETE ---------------

  # DELETE w body
  # SHOULD RAISE bc contains body
  let(:delete_w_body) do
    {
      'REQUEST_METHOD' => 'DELETE',
      'rack.input' => StringIO.new('Body')
    }
  end

  # DELETE no accept or content-type headers
  # SHOULD PASS
  let(:delete_no_content_type_or_accept) do
    {
      'REQUEST_METHOD' => 'DELETE'
    }
  end

  # DELETE w content
  # SHOULD RAISE
  let(:delete_w_content_type) do
    {
      'REQUEST_METHOD' => 'DELETE',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # DELETE w accept jsonapi
  # SHOULD PASS
  let(:delete_accept_jsonapi) do
    {
      'REQUEST_METHOD' => 'DELETE',
      'HTTP_ACCEPT' => 'application/vnd.api+json'
    }
  end
  
  # DELETE w accept not jsonapi
  # SHOULD RAISE even though the middleware wouldn't check for compliance
  let(:delete_not_accept_jsonapi) do
    {
      'REQUEST_METHOD' => 'DELETE',
      'HTTP_ACCEPT' => 'text/html'
    }
  end
end
