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
    @status = 'Loos'
  end

  def response
    case @request.path
    when '/' then index
    when '/index' then game
    # when '/game' then start
    when '/check_data' then check_data #play_session
    when '/hint' then hint
    when '/login' then login
    when '/score' then score
    else Rack::Response.new(render('404'), 404)
    end
  end

  def hint
    @game.get_a_hint
    redirect_to('/')
  end

  def check_data
    # result = @game.match_result
    @game.validate_turn(@request.params['player_code'])
    # show_statistic
    if @game.match_result == '++++'
      @status = 'Won'
    else
      @status = 'Loos'
    end
    
    if @game.hints == 0 || @game.total_attempts <= 0 && @game.turns >= 6
      @status = 'Loos'
      redirect_to('/login')
    else
      @status = 'Won'
    end
    redirect_to('/')
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
    @player_name = 
    game_result = @status ? 'Win' : 'Loos'
    session_statistic = @game.turn_statistic
    log = { @player_name.to_s => [
                              "Date: #{session_statistic}",
                              'hints geting' => @game.hints_used,
                              'Status of game' => game_result
                              ] }
  end

  private

  def index
    # @request.session.clear
    # @request.session[:name]
    # @request.params['name']
    # user_name(@request.params['name'])
    # start
    Rack::Response.new(render('index'))
    # result = @game.match_result
    # @request.session[:game_status] = 'won' if result == '++++'
  end

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

  def the_view_for_the_winner
    @status = 'Win'
    reset_game
  end

  def the_view_for_the_loser
    @game.code_view_with_hint
    @status = 'Loos'
    reset_game
  end

  def reset_game
    save_result
    @request.session.clear

    redirect_to('/')
  end

  def save_result
    File.open(@path_to_file, 'a') do |f|
      f.puts get_data_to_save_statistic
    end
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

  def save_game
    @request.session[:game] = @game
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
