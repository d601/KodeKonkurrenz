class AddRatedToGames < ActiveRecord::Migration
  def change
    add_column :games, :rated, :boolean
  end
end
