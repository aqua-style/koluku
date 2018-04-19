class AddOmutuSpaceToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :omutu_space, :integer, default: 0
  end
end
