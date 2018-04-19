class AddKidsSpaceToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :kids_space, :integer, default: 0
  end
end
