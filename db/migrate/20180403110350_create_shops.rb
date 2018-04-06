class CreateShops < ActiveRecord::Migration[5.0]
  def change
    create_table :shops do |t|
      t.string :name
      t.string :y_id
      t.string :y_gid
      t.string :y_uid
      t.string :y_ido
      t.string :y_keido
      t.string :y_address
      t.string :y_leadimage
      t.boolean :close_flg, default: false, null: false

      t.timestamps
    end
  end
end
