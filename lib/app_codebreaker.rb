require 'haml'
require 'yaml'
require 'codebreaker'
require_relative 'router'

# class AppCodebreaker
class AppCodebreaker
  include Codebreaker

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @game = Codebreaker::Game.new
    @secret_code = @game.code_view_with_hint
    @total_attempts = ATTEMPTS
    @hints = HINTS
    @hints_used = 0
    @player_name = 'Ananimus'
    # @player_name = response.player_name
    # @match_result = ''
    # @turn = 1
    # @turn_statistic = {}

    @path_to_file = PATH_TO_LOG_FILES
    # @status = false
    # @game_data_file_path = File.join(__dir__, 'game_data.yml')
    # @scores = {}
  end

  def response
    page = Routes::APP_ROUTES[@request.path]
    page ? page.call(self) : Rack::Response.new(render('404'), 404)
  end

  def index
    # if @request.params['player_name']
    #   self.player_name = @request.params['player_name'].strip unless player_name
    #   self.game = Codebreaker::Game.new unless game
    #   game.start
    # end
    Rack::Response.new(render 'index')
  end

  # def check_guess
  #   player_code = @request.params['player_code']
  #   # game.make_attempt(guess)
  #   # @game.validate_turn(player_code)
  #   start_game
  #   # add_to_log
  #   redirect_to '/'
  # end

  def start_game
    @game.validate_turn(player_code)
  end
  # def add_to_log
  #   self.game_log = game_log || []
  #   game_log << [guess, game.attempt_result]
  # end

  # def show_hint
  #   self.hint = game.hint
  #   redirect_to '/'
  # end

  # def game_restart
  #   @request.session.clear
  #   redirect_to '/'
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
