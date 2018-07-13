require_relative 'config/application'

@app = WebCodeBreackerRacker.new

use Rack::Reloader, 0
use Rack::Static, urls: ['/css', '/images'], root: 'public'

run @app
