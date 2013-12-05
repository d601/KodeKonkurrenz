class AddIsSubmitted2ToGames < ActiveRecord::Migration
  def change
    add_column :games, :isSubmitted2, :bool
  end
end
