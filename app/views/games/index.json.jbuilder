json.array!(@games) do |game|
  json.extract! game, :time_limit, :player1_id, :player2_id, :problem_id, :winner_id, isPractice
  json.url game_url(game, format: :json)
end
