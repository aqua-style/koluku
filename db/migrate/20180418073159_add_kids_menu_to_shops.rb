class AddKidsMenuToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :kids_menu, :integer, default: 0
  end
end
