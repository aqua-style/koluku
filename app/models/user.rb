class User < ApplicationRecord
  before_save { self.email.downcase! }

  validates :nickname, presence: true, length: { maximum: 50 }
  validates :intro, length: { maximum: 255 }
  validates :live, length: { maximum: 50 }

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
                    
  has_many :kuchikomis
  has_secure_password
  
  #カラムの名前をmount_uploaderに指定
  mount_uploader :image, ImageUploader
end
