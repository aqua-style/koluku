class AddKozureOkToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :kozure_ok, :integer, default: 0
  end
end
