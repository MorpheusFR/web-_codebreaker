module GameSessionStore
  def player_name
    @request.session[:player_name]
  end

  def player_name=(name)
    @request.session[:player_name] = name
  end

  def game
    @request.session[:game]
  end

  def game=(value)
    @request.session[:game] = value
  end

  def guess
    @request.session[:guess]
  end

  def guess=(value)
    @request.session[:guess] = value
  end

  def game_log
    @request.session[:game_log]
  end

  def game_log=(value)
    @request.session[:game_log] = value
  end

  def hint
    @request.session[:hint]
  end

  def hint=(value)
    @request.session[:hint] = value
  end
end