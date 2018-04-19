class AddBabycarToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :babycar, :integer, default: 0
  end
end
