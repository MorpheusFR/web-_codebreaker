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
    @game = load_game
    @path_to_file = PATH_TO_LOG_FILES
    @status = ''
  end

  def response
    case @request.path
    when '/' then index
    # when '/index' then game
    # when '/game' then start
    when '/check_data' then check_data #play_session
    when '/hint' then hint
    when '/login' then login
    when '/save_result' then save_result
    when '/reset' then reset_game
    when '/score' then score
    else Rack::Response.new(render('404'), 404)
    end
  end

  def index
    Rack::Response.new(render('index'))
  end

  def hint
    @game.get_a_hint
    redirect_to('/')
  end

  def check_data
    @game.validate_turn(@request.params['player_code'])
    # @status = 'Won' if @game.match_result == '++++'
    if @game.winner? #|| @game.total_attempts <= 0 && @game.turns > 6
      @status = 'Won'
      redirect_to('/login')
    end
    if @game.total_attempts <= 0 || @game.hints.zero?
      @status = 'Loos'
      redirect_to('/')
    end
  end

  def game
    result = @game.match_result
    @request.session[:game_status] = 'won' if @game.match_result == '++++'
    if @game.match_result == '++++'
      @status = 'Won'
    end 
    start
    # @user_name = @request.params['name']
    redirect_to('/')
  end

  def show_statistic
    @statistic = []
    @statistic.push('Total attempt = ' + @game.total_attempts.to_s,
                    'Secret code = ' + @game.code_view_with_hint,
                    'Match result = ' + @game.match_result,
                    'Hints = ' + @game.hints.to_s)
  end

  def input_data
    input_data = @request.params['player_code']
    check_data(input_data)
  end

  def login
    @player_name = @request.params['name']
    @request.session[:game_status]
    get_data_to_save_statistic
  end

  def get_data_to_save_statistic
    @player_name = @request.params['name']
    game_result = @status ? 'Win' : 'Loos'
    session_statistic = @game.turn_statistic
    log = { @player_name.to_s => [
                              "Date: #{session_statistic}",
                              'hints geting' => @game.hints_used,
                              'Status of game' => game_result
                              ] }
  end

  private

  def score
    load_results
    Rack::Response.new(render('score'))
  end

  def start
    play_session
    redirect_to('/index')
  end

  def play_session
    show_statistic
    if @game.winner? || @game.hints.zero?
      
    end
    @game.winner? ? the_view_for_the_winner : the_view_for_the_loser
  end

  def reset_game
    @request.session.clear
    redirect_to('/')
  end

  def result_on_input_data(input_data)
    begin
      @game.validate_turn input_data
    rescue ArgumentError
      'ArgumentError message: invalid value, try retrying!'
    end
  end

  def load_game
    @request.session[:game] ||= Codebreaker::Game.new
  end

  def save_result
    @request.session[:game] = @game
    File.open(@path_to_file, 'a') do |f|
      f.puts get_data_to_save_statistic
    end
  end

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
