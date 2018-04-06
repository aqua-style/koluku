class AddOsusumeToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :osusume, :boolean, default: false, null: false
  end
end
