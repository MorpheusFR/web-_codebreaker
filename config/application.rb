class WebCodeBreackerRacker
  def call(env)
    body = "<h1>This is Rack! First</h1>" \
           "<p>Rack is ease..</p>"
    [ 200, { 'Content-Type' => 'text/html' }, [body] ]
  end
end
