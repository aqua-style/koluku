class AddEkitikaToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :ekitika, :integer, default: 0
  end
end
