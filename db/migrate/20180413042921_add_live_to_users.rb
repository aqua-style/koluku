class AddLiveToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :live, :string
  end
end
