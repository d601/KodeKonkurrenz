class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.decimal :time
      t.integer :difficulty
      t.integer :category

      t.timestamps
    end
  end
end
