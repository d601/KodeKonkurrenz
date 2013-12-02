class AddAgeGenderSchoolAboutToUser < ActiveRecord::Migration
  def change
    add_column :users, :age, :integer , default: 0
    add_column :users, :gender, :string , default: 'none'
    add_column :users, :school, :string , default: 'none'
    add_column :users, :about, :text 
  end
end
