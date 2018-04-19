class AddKangeiToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :kangei, :integer, default: 0
  end
end
