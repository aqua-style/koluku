class AddSyoukaiToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :syoukai, :text
  end
end
