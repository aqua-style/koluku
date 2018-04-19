class AddEiseiToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :eisei, :integer, default: 0
  end
end
