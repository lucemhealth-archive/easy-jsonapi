# frozen_string_literal: true

shared_context 'headers exceptions' do
  
  let(:hec) { JSONAPI::Exceptions::HeadersExceptions::InvalidHeader }
  
  # Should pass
  let(:env1) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'text/plain'
    }
  end

  # Should pass
  let(:env2) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # Should pass
  let(:env3) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end
  
  # Should raise error bc of content type
  let(:env4) do
    {
      'HTTP_ACCEPT' => 'text/plain',
      'CONTENT_TYPE' => 'application/vnd.api+json; idk'
    }
  end

  # Should raise error because of HTTP_ACCEPT
  let(:env5) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json ; q=0.5, text/*, image/* ; q=.3',
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  # Should raise error because of both
  let(:env6) do
    {
      'HTTP_ACCEPT' => 'application/vnd.api+json ; q=0.5, text/*, image/* ; q=.3',
      'CONTENT_TYPE' => 'application/vnd.api+json ; idk'
    }
  end
end
