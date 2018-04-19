class AddSmokingToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :smoking, :integer, default: 0
  end
end
