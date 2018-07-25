require 'haml'
require 'yaml'
require 'codebreaker'
require_relative 'router'
require_relative 'game_session_store'

# class AppCodebreaker
class AppCodebreaker
  include Codebreaker
  include GameSessionStore

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @game = Codebreaker::Game.new
    # @game_console = Codebreaker::GameConsole.new
    @secret_code = @game.code_view_with_hint
    @path_to_file = PATH_TO_LOG_FILES
    @status = false
    @player_name = nil
    @total_attempts = total_attempts
    @match_result = match_result
  end

  def response
    case @request.path
    when '/'
      @request.session.clear
      Rack::Response.new(render('index'))
    when '/index' then Rack::Response.new(render('game_session'))
    when '/game'
      start unless @request.session[:coregame]
      Rack::Response.new(render('game'))
    when '/game_session'
      start_game unless @request.session[:game]
      Rack::Response.new(render('game_session'))
    when '/submit_code'
      submit_code(@request.params['player_code'])
      Rack::Response.new { |response| response.redirect('/game_session') }
    when '/hints'
      hints
      Rack::Response.new { |response| response.redirect('/game') }
    when '/enter_name'
      enter_name(@request.params['name'])
      Rack::Response.new { |response| response.redirect('/score') }
    when '/score'
      load_results
      Rack::Response.new(render('score'))
    else Rack::Response.new(render('404'), 404)
    end
  end

  private

  def start
    @game = Codebreaker::Game.new
    @secret_code = @game.code_view_with_hint
    @request.session[:coregame] = @game
  end

  def submit_code(input_code='1111')
    @request.session[:coregame].validate_turn(input_code)

    # player_result = @request.session[:coregame].match_result
    # @request.session[:coregame].validate_turn(input_code)
    # @request.session[:game].result_on_input_data(user_input)
    # @request.session[:attempts] << { input_code: input_code, player_result: player_result }
  end

  def hints
    @request.session[:coregame].get_a_hint
  end

  def secret_code
    @secret_code
  end

  def input_code
    @request.params[player_code]
  end

  def validate_turn
    @request.session[:coregame].validate_turn(@request.params[input_code])
    @match_result = @request.session[:match_result]
    @request.session[:coregame].counter_attepmpts_and_turn
  end

  def match_result
    @request.session[:total_attempts]
  end

  def total_attempts
    @request.session[:total_attempts]
  end

  # def load_results
  #   @results = YAML.load(RgHwCodebreaker::ResultsAccessor.load_results_file)
  #   @results_table_header = @results.shift
  # end

  # def start_game
  #   @player_name = @request.params[player_name]
  #   @request.session[:game] = Codebreaker::Game.new
  #   @request.session[:player_name] = @request.params[player_name]
  #   @request.session[:game].code_view_with_hint
  #   @request.session[:attempts] = []
  #   @request.session[:hint]
  # end

  # def submit_guess(input_code)
  #   if @request.session[:game].validate_turn(input_code)
  #     player_result = @request.session[:game].match_result
  #     @request.session[:attempts] << { input_code: input_code, player_result: player_result }
  #   else
  #     @request.session[:error_msg] = 'Your input is invalid'
  #   end
  # end

  # def enter_name(player_name)
  #   current_result = [player_name, Date.today, 10 - @request.session[:game].turns]
  #   Codebreaker::ResultsAccessor.write_result_to_file(current_result)
  #   @request.session[:notice_msg] = 'Your result saved'
  # end

  # def hint
  #   @request.session[:hint] = true
  #   @request.session[:hint] = if @request.session[:game].any_hints_left?
  #                               "Hint: #{@request.session[:game].get_a_hint}***"
  #                             else
  #                               'No hints left :('
  #                             end
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
