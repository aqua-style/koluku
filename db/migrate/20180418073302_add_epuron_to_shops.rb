class AddEpuronToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :epuron, :integer, default: 0
  end
end
