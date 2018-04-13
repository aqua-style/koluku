class Kuchikomi < ApplicationRecord
  belongs_to :shop
  belongs_to :user, optional: true
    
  validates :shop_id, presence: true #カラは駄目
  validates :comment, length: { maximum: 255 }

end
