class AddIsSubmittedToGames < ActiveRecord::Migration
  def change
    add_column :games, :isSubmitted, :bool
  end
end
