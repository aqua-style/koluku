class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception


  #herokuapp.comから独自ドメインへリダイレクト
  before_filter :ensure_domain
  FQDN = 'www.koluku.net'
  # redirect correct server from herokuapp domain for SEO
  def ensure_domain
   return unless /\.herokuapp.com/ =~ request.host
  
   # 主にlocalテスト用の対策80と443以外でアクセスされた場合ポート番号をURLに含める 
   port = ":#{request.port}" unless [80, 443].include?(request.port)
   redirect_to "#{request.protocol}#{FQDN}#{port}#{request.path}", status: :moved_permanently
  end


  include SessionsHelper
  
  private

  def require_user_logged_in
    unless logged_in?
      redirect_to login_url
    end
  end

end
