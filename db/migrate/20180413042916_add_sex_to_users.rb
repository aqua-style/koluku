class AddSexToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :Sex, :integer,:limit => 1
  end
end
