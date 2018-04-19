class AddNyujiOkToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :nyuji_ok, :integer, default: 0
  end
end
