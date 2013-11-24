class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.decimal :time_limit
      t.integer :player1_id
      t.integer :player2_id
      t.integer :problem_id
      t.integer :winner_id

      t.timestamps
    end
  end
end
