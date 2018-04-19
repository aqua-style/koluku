class AddJunyusituToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :junyusitu, :integer, default: 0
  end
end
