class AddZasikiToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :zasiki, :integer, default: 0
  end
end
