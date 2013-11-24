json.array!(@problems) do |problem|
  json.extract! problem, :time, :difficulty, :category
  json.url problem_url(problem, format: :json)
end
