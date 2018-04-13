class AddAgeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :age, :integer,:limit => 1
  end
end
