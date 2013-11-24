class AddDefaultsToGames < ActiveRecord::Migration
  def up
    change_column_default :games, :player2_id, -1
    change_column_default :games, :winner_id, -1
  end

  def down
    change_column_default :games, :player2_id, nil
    change_column_default :games, :winner_id, nil
  end
end
