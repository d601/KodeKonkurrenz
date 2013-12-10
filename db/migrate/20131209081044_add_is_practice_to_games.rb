class AddIsPracticeToGames < ActiveRecord::Migration
  def change
    add_column :games, :isPractice, :bool
  end
end
