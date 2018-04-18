class ShopPhotosController < ApplicationController
  
  def upload
    puts '◆upload'
  
    @shop_photo = ShopPhoto.new(shop_photo_params) 
    puts @shop_photo.inspect #中身表示
        
    if @shop_photo.save
      flash[:success] = '写真を投稿しました'
    else
      flash[:danger] = '写真の投稿に失敗しました'
      #元の画面に戻すためモデルを再設定 redirectで飛ばすから不要
      #@shop = Shop.find(@shop_photo.shop_id)
      #@kuchikomi = Kuchikomi.new
      #@kuchikomi.shop_id = @shop.id
      #@shop_photo = ShopPhoto.new
      #render 'shops/kuchikomi'
    end

      redirect_to kuchikomi_shop_url(@shop_photo.shop_id)    
  end
  
  private
  
  #ストロングパラメーター
  def shop_photo_params
    params.require(:shop_photo).permit(:shop_id, :user_id, :image)
  end
  
end
