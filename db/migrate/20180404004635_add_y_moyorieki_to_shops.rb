class AddYMoyoriekiToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :y_moyorieki, :string
  end
end
