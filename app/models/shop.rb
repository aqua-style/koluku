class Shop < ApplicationRecord
    validates :name, presence: true, length: { maximum: 255 } #店舗名はカラ駄目
    validates :y_gid, uniqueness: true
    has_many :kuchikomis
    #accepts_nested_attributes_for :kuchikomis #子レコードを作成する用 #意味がわからないのでやめる
    #has_many :get_kuchikomi_users, through: :kuchikomis, source: :user #口コミをしたユーザー情報を取るためのメソッドkuchikomis中間テーブルを経由してとる。
    
    has_many :shop_photos
end
