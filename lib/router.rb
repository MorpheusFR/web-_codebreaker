module Routes
  APP_ROUTES = {
    '/' => ->(instance) { instance.index },
    '/index' => ->(instance) { instance.index },
    '/game_session' => ->(instance) { instance.game_session },
    # '/hint' => ->(instance) { instance.show_hint },
    # '/restart' => ->(instance) { instance.game_restart },
    # '/save' => ->(instance) { instance.save_game_result },
    '/scores' => ->(instance) { instance.show_scores }
  }.freeze
end