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
    @secret_code = @game.code_view_with_hint
    @path_to_file = PATH_TO_LOG_FILES
    @status = false
    @player_name = nil
    @total_attempts = ATTEMPTS
    @hints = HINTS
    @hints_used = 0
  end

  def response
    case @request.path
    when '/'
      @request.session.clear
      Rack::Response.new(render('index'))
    when '/index' then Rack::Response.new(render('game_session'))
    when '/game_session'
      start_game unless @request.session[:game]
      Rack::Response.new(render('game_session'))
    when '/submit_guess'
      submit_guess(@request.params['guess'])
      Rack::Response.new { |response| response.redirect('/game') }
    # when '/show_hint'
    #   show_hint
    #   Rack::Response.new { |response| response.redirect('/game') }
    # when '/enter_name'
    #   enter_name(@request.params['name'])
    #   Rack::Response.new { |response| response.redirect('/best_results') }
    # when '/best_results'
    #   load_results
    #   Rack::Response.new(render('best_results.html.erb'))
    else Rack::Response.new(render('404'), 404)
    end
  end

  private

  # def load_results
  #   @results = YAML.load(RgHwCodebreaker::ResultsAccessor.load_results_file)
  #   @results_table_header = @results.shift
  # end

  def start_game
    @player_name = @request.params[player_name]
    @request.session[:game] = Codebreaker::Game.new
    @request.session[:player_name] = @request.params[player_name]
    @request.session[:game].code_view_with_hint
    @request.session[:attempts] = []
    @request.session[:show_hint] = false
  end

  def submit_guess(guess)
    if @request.session[:game].valid_guess?(guess)
      guess_result = @request.session[:game].check_guess(guess)
      @request.session[:attempts] << { guess: guess, guess_result: guess_result }
    else
      @request.session[:error_msg] = 'Your input is invalid'
    end
  end

  def enter_name(player_name)
    current_result = [player_name, Date.today, 10 - @request.session[:game].turns]
    RgHwCodebreaker::ResultsAccessor.write_result_to_file(current_result)
    @request.session[:notice_msg] = 'Your result saved'
  end

  def hint
    @request.session[:hint] = true
    @request.session[:hint] = if @request.session[:game].any_hints_left?
                                "Hint: #{@request.session[:game].give_a_hint}***"
                              else
                                'No hints left :('
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
