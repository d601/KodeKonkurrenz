class AddRatingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rating, :integer, default: 1450
  end
end
