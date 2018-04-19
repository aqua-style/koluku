class AddSekiHiroiToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :seki_hiroi, :integer, default: 0
  end
end
