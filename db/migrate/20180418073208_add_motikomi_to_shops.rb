class AddMotikomiToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :motikomi, :integer, default: 0
  end
end
