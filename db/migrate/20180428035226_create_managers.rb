class CreateManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :managers do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.integer :level,:limit => 1
      t.string :image

      t.timestamps
    end
  end
end
