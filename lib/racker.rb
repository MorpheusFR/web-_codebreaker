require 'haml'
require 'yaml'
require 'morph_codebreaker'
require_relative 'router'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    page = Routes::APP_ROUTES[@request.path]
    page ? page.call(self) : Rack::Response.new(render('404'), 404)
    # case @request.path
    # when '/' then Rack::Response.new(render('index'))
    # when '/guess' then make_guess
    # when '/hint' then hint
    # when '/restart' then restart
    # when '/save' then save_result
    # when '/score' then score
    # # when '/' then Rack::Response.new(render('index'))
    # # when '/update_word'
    # #   Rack::Response.new do |response|
    # #     response.set_cookie('word', @request.params['word'])
    # #     response.redirect('/')
    # #   end
    # else Rack::Response.new(render('404'))
    # end
  end

  private

  # def render(template)
  #   Haml::Engine.new(File.read("public/views/#{template}.html.haml")).render
  # end

  def render(template)
    path = File.expand_path("../views/#{template}.html.haml", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end

  def redirect_to(path)
    Rack::Response.new do |response|
      response.redirect(path.to_s)
    end
  end
end
