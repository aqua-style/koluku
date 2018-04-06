class ShopsController < ApplicationController

  def index #ショップの一覧表示
    @shops = Shop.all
  end

  #ショップの一覧画面から初めて口コミ投稿されるときにこのアクションにくる→new.html.erbで投稿画面のformを出す→kuchikomi#createへ
  def new 
    @shop = Shop.new
  end

  #ショップのnew.html.erb画面からformで投稿されたらここにくる。ここで店保存、最初の口コミ保存を行う。
  def create
  end


  #ショップ一覧画面からショップの口コミ詳細をクリックしたらここに来て→show.html.erbを表示
  def show 
    @shop = Shop.find(params[:id])
  end


  #ショップ一覧画面から口コミするをクリックでここに来る（2回目以降の口コミ投稿の場合）→ kuchikomi.html.erbへ
  def kuchikomi
    @shop = Shop.find(params[:id])
    @kuchikomi = Kuchikomi.new
  end
  
  #ここで口コミ投稿させる
  def kuchikomi_create
  end

end
