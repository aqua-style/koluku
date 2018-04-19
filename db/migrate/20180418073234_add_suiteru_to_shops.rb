class AddSuiteruToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :suiteru, :integer, default: 0
  end
end
