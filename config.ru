require './lib/app_codebreaker'

use Rack::Reloader
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret_code'

run Rack::Cascade.new([Rack::File.new('public'), AppCodebreaker])
