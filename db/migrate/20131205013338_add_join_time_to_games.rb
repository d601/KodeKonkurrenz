class AddJoinTimeToGames < ActiveRecord::Migration
  def change
    add_column :games, :joinTime, :string
  end
end
