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
    @path_to_file = PATH_TO_LOG_FILES
    @status = false
    @player_name = @player_name
  end

  def response
    case @request.path
    when '/' #then index
      @request.session.clear
      index
    when '/index' then index
    when '/game' then game
    when '/hint' then hint
    when '/score' then score
    else Rack::Response.new(render('404'), 404)
    end
  end

  private

  def index
    start
    user_name(@request.params['player_name'])
    Rack::Response.new(render('game'))
  end

  def game
    # user_name(@request.params['player_name'])
    play_session(@request.params['player_code'])
    Rack::Response.new(render('game'))
  end

  def hint
    @game.get_a_hint
      # Rack::Response.new { |response| response.redirect('/game') }
  end

  def score
    load_results
    Rack::Response.new(render('score'))
  end

  def start
    @request.session[:coregame] = @request.params['player_name']
  end

  def play_session(input_data)
    show_statistic
    result_on_input_data(input_data)
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
    WON
    @status = true
    finish_or_reset_game
  end

  def the_view_for_the_loser
    THE_HINTS_ENDED
    @game.code_view_with_hint
    LOOS
    finish_or_reset_game
  end

  def finish_or_reset_game
    save_result
    RESTART_OR_BREAK
    start # if input_data == 'game'
  end

  def save_result
    File.open(@path_to_file, 'a') do |f|
      f.puts get_data_to_save_statistic
    end
  end

  def user_name(player)
    @player_name = player
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

  def show_congrats
    GREETING_MESSAGE
  end

  def show_rules
    RULES
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
