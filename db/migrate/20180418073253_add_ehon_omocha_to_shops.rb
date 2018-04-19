class AddEhonOmochaToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :ehon_omocha, :integer, default: 0
  end
end
