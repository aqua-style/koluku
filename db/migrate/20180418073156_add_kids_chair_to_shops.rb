class AddKidsChairToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :kids_chair, :integer, default: 0
  end
end
