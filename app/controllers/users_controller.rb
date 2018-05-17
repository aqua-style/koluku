class UsersController < ApplicationController
  
  before_action :require_user_logged_in, only: [:index, :update, :edit]
  
  #ユーザー一覧を表示する不要かも
  def index
      #@users = User.all.page(params[:page])
  end

  def show
      @user = User.find(params[:id])
  end

  def new
      puts '◆user#new'
      @user = User.new
  end

  def create
    puts '◆user#create'
    @user = User.new(user_params)

    puts @user
    if @user.save
      flash[:success] = '新しいユーザーを登録しました。'
      redirect_to @user
    else
      flash.now[:danger] = 'ユーザーの登録に失敗しました。'
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    redirect_to root_url if current_user != @user
  end
  
  def update
    puts '◆update'
    @user = User.find(params[:id])

    #編集しようとしてるユーザーがログインユーザーとイコールかをチェック
    if current_user == @user

      if @user.update(user_params)
        flash[:success] = 'ユーザー情報を編集しました。'
        render :edit
      else
        flash.now[:danger] = 'ユーザー情報の編集に失敗しました。'
        render :edit
      end    
    
    else
        redirect_to root_url
    end
      
    
  end





  private

  #ストロングパラメーター
  def user_params
    params.require(:user).permit(:nickname, :email, :password, :password_confirmation, :image, :intro, :age, :sex, :live)
  end



  
end
