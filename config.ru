# frozen_string_literal: true

require './lib/racker'

app_codebreaker = Rack::Builder.new do
  use Rack::Reloader, 0
  use Rack::Static, urls: ['/stylesheets', '/views'], root: 'public'
  use Rack::Session::Cookie, key: 'rack.session', secret: 'secret'

  run Racker
end

run app_codebreaker