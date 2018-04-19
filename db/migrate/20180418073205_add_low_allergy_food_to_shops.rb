class AddLowAllergyFoodToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :low_allergy_food, :integer, default: 0
  end
end
