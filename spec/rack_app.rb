# Demo Rack App to test middleware class locally.
class RackApp
  
  def call(env)
    req = Rack::Request.new(env)
    status = 200
    headers = { "Content-Type" => "text/plain" }
    body = 
      [
        'Testing'
      ]
    [status, headers, body]
  end
end
