class AddDefaultValueToIsPracticeAttribute < ActiveRecord::Migration
  def change
    change_column :games, :isPractice, :boolean, :default => false
  end
end
