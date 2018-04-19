class AddChusyajoToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :chusyajo, :integer, default: 0
  end
end
