class AddAccessToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :access, :integer, default: 0
  end
end
