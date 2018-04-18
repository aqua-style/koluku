class AddGyosyuToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :y_gyosyu, :string
  end
end
