class AddFamilymukeToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :familymuke, :integer, default: 0
  end
end
