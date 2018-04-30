class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]
    if login(email, password)
      flash[:success] = 'ログインに成功しました。'
      redirect_to @user
    else
      flash.now[:danger] = 'ログインに失敗しました。'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
  
  ###########管理者用##########
  def mngsessionnew
  end
  
  def mngcreate
    email = params[:session][:email].downcase
    password = params[:session][:password]
    if mnglogin(email, password)
      flash[:success] = 'ログインに成功しました。'
      redirect_to @mng
    else
      flash.now[:danger] = 'ログインに失敗しました。'
      redirect_to koluku_mng_login_url
    end
  end
  
  def mngdestroy
    session[:mng_id] = nil
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
  
  

  private

  def login(email, password)
    @user = User.find_by(email: email)
    if @user && @user.authenticate(password)
      # ログイン成功
      session[:user_id] = @user.id
      return true
    else
      # ログイン失敗
      return false
    end
  end
  
  def mnglogin(email, password)
    @mng = Manager.find_by(email: email)
    if @mng && @mng.authenticate(password)
      # ログイン成功
      session[:mng_id] = @mng.id
      return true
    else
      # ログイン失敗
      return false
    end
  end
  
end