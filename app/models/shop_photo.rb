class ShopPhoto < ApplicationRecord
  belongs_to :shop
  
  validates :image, presence: true
  
  mount_uploader :image, ImageUploader #careerwaveの関連付け
end
