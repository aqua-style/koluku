module SessionsHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

  def current_mng
    @current_mng ||= Manager.find_by(id: session[:mng_id])
  end

  def mng_logged_in?
    !!current_mng
  end

end