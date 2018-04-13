class ChangeDatatypeSexOfUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :sex, :string
  end
end
