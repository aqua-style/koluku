class AddKidsSyokkiToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :kids_syokki, :integer, default: 0
  end
end
