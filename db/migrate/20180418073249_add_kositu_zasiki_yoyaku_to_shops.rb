class AddKosituZasikiYoyakuToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :kositu_zasiki_yoyaku, :integer, default: 0
  end
end
