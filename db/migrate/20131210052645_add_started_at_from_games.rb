class AddStartedAtFromGames < ActiveRecord::Migration
  def change
    add_column :games, :started_at, :datetime
  end
end
