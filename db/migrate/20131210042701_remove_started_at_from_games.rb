class RemoveStartedAtFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :started_at, :datetime
  end
end
