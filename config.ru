require './lib/app_codebreaker'

use Rack::Reloader, 0
use Rack::Session::Cookie , key: 'rack.session',
                           path: '/'
                          #  secret: 'Qwerty'

run Rack::Cascade.new([Rack::File.new('public'), AppCodebreaker])
