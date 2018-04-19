class AddKosituToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :kositu, :integer, default: 0
  end
end
