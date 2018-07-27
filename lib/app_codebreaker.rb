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
    when '/game' then start
    when '/hint' then hint
    when '/score' then score
    else Rack::Response.new(render('404'), 404)
    end
  end

  private

  def index
    # start
    # @request.session.clear
    @request.session[:name]
    @request.params['name']
    user_name(@request.params['name'])
    Rack::Response.new(render('index'))
  end

  def game
    # @game.validate_turn(@request.params['player_code'])
    result = @game.match_result
    # save_game
    @request.session[:game_status] = 'won' if result == '++++'

    # redirect_to('/')
    start
    @user_name = @request.params['name']
    
    redirect_to('/')
  end

  def hint
    @game.get_a_hint
    @request.session[:hint] = @game.hints
    @request.session[:hints_used] = @game.hints_used
    redirect_to('/')
  end

  def score
    load_results
    Rack::Response.new(render('score'))
  end

  def start
    play_session
    redirect_to('/')
  end

  def play_session #(input_data)
    show_statistic
    #result_on_input_data(@request.params['player_code'])
    if @game.winner? || @game.hints.zero?
    end
    @game.winner? ? the_view_for_the_winner : the_view_for_the_loser
  end

  def show_statistic
    @statistic = []
    @statistic.push('Total attempt = ' + @game.total_attempts.to_s,
                    'Secret code = ' + @game.code_view_with_hint,
                    'Match result = ' + @game.match_result,
                    'Hints = ' + @game.hints.to_s)
  end

  def the_view_for_the_winner
    @status = 'Win'
    reset_game
  end

  def the_view_for_the_loser
    # @request.session[:game].code_view_with_hint
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


  def get_data_to_save_statistic
    # @player_name
    game_result = @status ? 'Win' : 'Loos'
    session_statistic = @game.turn_statistic
    log = { @player_name.to_s => [
                              "Date: #{session_statistic}",
                              'hints geting' => @game.hints_used,
                              'Status of game' => game_result
                              ] }
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
