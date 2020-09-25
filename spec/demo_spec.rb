# frozen_string_literal: true

require 'rack/test'
require 'hello_world'

ENV['APP_ENV'] = 'test'

RSpec.describe 'The HelloWorld App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'says hello' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Hello World!')
  end
end
