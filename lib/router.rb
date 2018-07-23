module Routes
  APP_ROUTES = {
    '/' => ->(instance) { instance.index },
    '/check' => ->(instance) { instance.check_guess },
    # '/hint' => ->(instance) { instance.show_hint },
    # '/restart' => ->(instance) { instance.game_restart },
    # '/save' => ->(instance) { instance.save_game_result },
    '/scores' => ->(instance) { instance.show_scores }
  }.freeze
end