class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  #20190718 独自ドメインwww.koluku.netへ飛ばすのを止める

  include SessionsHelper
  
  private

  def require_user_logged_in
    unless logged_in?
      redirect_to login_url
    end
  end

end
