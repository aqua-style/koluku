class CreateKuchikomis < ActiveRecord::Migration[5.0]
  def change
    create_table :kuchikomis do |t|
      t.integer :user_id
      t.references :shop, foreign_key: true
      t.integer :kozure_ok,:limit => 1
      t.integer :nyuji_ok,:limit => 1
      t.integer :smoking,:limit => 1
      t.integer :familymuke,:limit => 1
      t.integer :nigiyaka,:limit => 1
      t.integer :kids_chair,:limit => 1
      t.integer :kids_menu,:limit => 1
      t.integer :kids_syokki,:limit => 1
      t.integer :low_allergy_food,:limit => 1
      t.integer :motikomi,:limit => 1
      t.integer :zasiki,:limit => 1
      t.integer :kositu,:limit => 1
      t.integer :junyusitu,:limit => 1
      t.integer :omutu_space,:limit => 1
      t.integer :kids_space,:limit => 1
      t.integer :babycar,:limit => 1
      t.integer :hirosa,:limit => 1
      t.integer :seki_hiroi,:limit => 1
      t.integer :suiteru,:limit => 1
      t.integer :chusyajo,:limit => 1
      t.integer :ekitika,:limit => 1
      t.integer :access,:limit => 1
      t.integer :kangei,:limit => 1
      t.integer :kositu_zasiki_yoyaku,:limit => 1
      t.integer :ehon_omocha,:limit => 1
      t.integer :epuron,:limit => 1
      t.integer :eisei,:limit => 1
      t.string :comment

      t.timestamps
    end
  end
end
