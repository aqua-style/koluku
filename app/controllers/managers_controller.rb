class ManagersController < ApplicationController

  before_action :require_mng_logged_in, only: [:show]

  def show
    if current_mng.id != params[:id].to_i #ログイン管理者が他者をみないように
      redirect_to current_mng
    else
      @mng = Manager.find(params[:id])
      if @mng.level == 1 #スーパー管理者なら
        @shops = Shop.all
      end
    end
      
  end
  
  #ショップ編集画面の表示
  def shop_hensyu
    @mng = current_mng
    @shops = Shop.all
    @shop = Shop.find(params[:shop][:id].to_i)
    puts @shop.inspect
  end
  
  
  include SessionsHelper
  
  private

  def require_mng_logged_in
    unless mng_logged_in?
      redirect_to login_url
    end
  end
  
end
