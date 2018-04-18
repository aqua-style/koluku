class CreateShopPhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :shop_photos do |t|
      t.references :shop, foreign_key: true
      t.integer :user_id
      t.string :image

      t.timestamps
    end
  end
end
