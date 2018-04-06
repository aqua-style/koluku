class Kuchikomi < ApplicationRecord
  belongs_to :shop
  
  validates :shop_id, presence: true #カラは駄目
  validates :comment, length: { maximum: 255 }

end
