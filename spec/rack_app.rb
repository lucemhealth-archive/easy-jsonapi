# frozen_string_literal: true

# A simple rack app to use for testing
class RackApp
  
  def call(env)
    req = Rack::Request.new(env)
    pp req.params
    status = 200
    headers = { 'Content-Type' => 'text/plain' }
    body = 
      [
        "
          #{env.map { |h, v| "#{h} => #{v}" if h.start_with?('HTTP_') }}
        "
      ]
    [status, headers, body]
  end
end
