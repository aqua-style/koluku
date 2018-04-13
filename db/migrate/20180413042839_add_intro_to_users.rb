class AddIntroToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :intro, :string
  end
end
