class AddNigiyakaToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :nigiyaka, :integer, default: 0
  end
end
