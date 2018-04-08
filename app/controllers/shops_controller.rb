require 'net/http'
require 'uri'
require 'json'
class ShopsController < ApplicationController

  def index #ショップの一覧表示
    #@shops = Shop.all

    @shops = []

    @keyword = params[:keyword] #検索KWを取る
    
    puts @keyword
    
    if @keyword.present?
      #output = json / sort=matchマッチ順 hybrid組み合わせ / gc=01（グルメ）/ results=10（取得件数）
      yquery = 'https://map.yahooapis.jp/search/local/V1/localSearch?output=json&appid=' + ENV['YAHOO_API_KEY'] +  '&sort=hybrid&gc=01&results=10&query=' + @keyword
      
      puts '◆クエリは' + yquery

      yquery_enc = URI.encode yquery      #日本語を%のUTF-8の形にエンコード
      uri = URI.parse(yquery_enc)
      json = Net::HTTP.get(uri)
      @results = JSON.parse(json)         #配列形式に変換
      @features = @results['Feature']     #Feature配下の配列のみとりだす
      
      puts '◆JSONは'
      puts @results
      
      
      if @features.present? #結果がカラ（0件）じゃなければ。これをやらないとエラーでる。
      
        @features.each_with_index do |feature,i| #@features配列から1個1個とりだしてshopのインスタンスを生成していく
        
          unless feature['Property'].present?  #propertyがカラなら
            uid = nil
            address = nil
            image_url = nil
          else                                  #propertyがあるなら
            uid = feature['Property']['Uid']
            address = feature['Property']['Address']
            image_url = feature['Property']['LeadImage']
            
            #なかのstationがあるかチェック        
            unless feature['Property']['Station'][0].present? #nil.['Railway']とやるとエラーでるからチェックしないといけない #stationがカラなら
            	eki = nil
            else  #stationがあるなら
            	eki = feature['Property']['Station'][0]['Railway'] + "　" + feature['Property']['Station'][0]['Name']+"駅 徒歩" + feature['Property']['Station'][0]['Time'] + "分"
            end
          end
          
          unless feature['Geometry'].present? #Geometryがカラなら
            ido = nil
            keido = nil
          else                                #Geometryがあるなら
            unless feature['Geometry']['Coordinates'].present? #Coordinatesがカラなら
              ido = nil
              keido = nil
            else
              ido = feature['Geometry']['Coordinates'].split(",")[1]
              keido = feature['Geometry']['Coordinates'].split(",")[0]
            end
          end
    
          @shops[i] = Shop.new(
            name: feature['Name'],
            y_id: feature['Id'], 
            y_gid: feature['Gid'], 
            y_uid: uid,                                              #feature['Property']['Uid'], 
            y_ido: ido,                                              #feature['Geometry']['Coordinates'].split(",")[1], 
            y_keido: keido,                                          #feature['Geometry']['Coordinates'].split(",")[0], 
            y_address: address,                                      #feature['Property']['Address'], 
            y_moyorieki: eki,                                        #feature['Property']['Station'][0]['Railway'] + "　" + feature['Property']['Station'][0]['Name']+"駅 徒歩" + feature['Property']['Station'][0]['Time'] + "分"
            y_leadimage: image_url                                   #feature['Property']['LeadImage']
          )
        end #ループ
      end   #@feature.present?
      
      puts '◆@shops'
      puts @shops

      
    end

    #ここでDB内のshopsとマージ　後で実装
  end


  #ショップの一覧画面から初めて口コミ投稿されるときにこのアクションにくる→new.html.erbで投稿画面のformを出す→kuchikomi#createへ
  def new
    puts '■newきた'    
    
    #index.html.erbからURLクエリで送られてきた店舗情報を展開してハッシュに入れる、これを次のnew画面にもっていく
    @hash = {}
    request.query_parameters.each do |key, value|
    @hash[key] = value.to_s
    puts @hash[key]
  end
  
  puts @hash


  @kuchikomi = Kuchikomi.new
  @shop = Shop.new

  end

  #ショップのnew.html.erb画面からformで投稿されたらここにくる。ここで店保存、最初の口コミ保存を行う。
  def create
    
    #このなかでaccepts_nested_attributes_for をつかう
    
    puts '◆createきた'
    
  end


  #ショップ一覧画面からショップの口コミ詳細をクリックしたらここに来て→show.html.erbを表示
  def show 
    @shop = Shop.find(params[:id])
    
    #ここでカウント
    @kozure_ok_1 = Kuchikomi.where(shop_id: @shop.id).where(kozure_ok: 1).count
    @kozure_ok_2 = Kuchikomi.where(shop_id: @shop.id).where(kozure_ok: 2).count
    @nyuji_ok_1 = Kuchikomi.where(shop_id: @shop.id).where(nyuji_ok: 1).count
    @nyuji_ok_2 = Kuchikomi.where(shop_id: @shop.id).where(nyuji_ok: 2).count
    @smoking_1 = Kuchikomi.where(shop_id: @shop.id).where(smoking: 1).count
    @smoking_2 = Kuchikomi.where(shop_id: @shop.id).where(smoking: 2).count
    @smoking_3 = Kuchikomi.where(shop_id: @shop.id).where(smoking: 3).count
    @familymuke_1 = Kuchikomi.where(shop_id: @shop.id).where(familymuke: 1).count
    @familymuke_2 = Kuchikomi.where(shop_id: @shop.id).where(familymuke: 2).count
    @nigiyaka_1 = Kuchikomi.where(shop_id: @shop.id).where(nigiyaka: 1).count
    @nigiyaka_2 = Kuchikomi.where(shop_id: @shop.id).where(nigiyaka: 2).count
    @kids_chair_1 = Kuchikomi.where(shop_id: @shop.id).where(kids_chair: 1).count
    @kids_chair_2 = Kuchikomi.where(shop_id: @shop.id).where(kids_chair: 2).count
    @kids_menu_1 = Kuchikomi.where(shop_id: @shop.id).where(kids_menu: 1).count
    @kids_menu_2 = Kuchikomi.where(shop_id: @shop.id).where(kids_menu: 2).count
    @kids_syokki_1 = Kuchikomi.where(shop_id: @shop.id).where(kids_syokki: 1).count
    @kids_syokki_2 = Kuchikomi.where(shop_id: @shop.id).where(kids_syokki: 2).count
    @low_allergy_food_1 = Kuchikomi.where(shop_id: @shop.id).where(low_allergy_food: 1).count
    @low_allergy_food_2 = Kuchikomi.where(shop_id: @shop.id).where(low_allergy_food: 2).count
    @motikomi_1 = Kuchikomi.where(shop_id: @shop.id).where(motikomi: 1).count
    @motikomi_2 = Kuchikomi.where(shop_id: @shop.id).where(motikomi: 2).count
    @zasiki_1 = Kuchikomi.where(shop_id: @shop.id).where(zasiki: 1).count
    @zasiki_2 = Kuchikomi.where(shop_id: @shop.id).where(zasiki: 2).count
    @kositu_1 = Kuchikomi.where(shop_id: @shop.id).where(kositu: 1).count
    @kositu_2 = Kuchikomi.where(shop_id: @shop.id).where(kositu: 2).count
    @junyusitu_1 = Kuchikomi.where(shop_id: @shop.id).where(junyusitu: 1).count
    @junyusitu_2 = Kuchikomi.where(shop_id: @shop.id).where(junyusitu: 2).count
    @omutu_space_1 = Kuchikomi.where(shop_id: @shop.id).where(omutu_space: 1).count
    @omutu_space_2 = Kuchikomi.where(shop_id: @shop.id).where(omutu_space: 2).count
    @kids_space_1 = Kuchikomi.where(shop_id: @shop.id).where(kids_space: 1).count
    @kids_space_2 = Kuchikomi.where(shop_id: @shop.id).where(kids_space: 2).count
    @babycar_1 = Kuchikomi.where(shop_id: @shop.id).where(babycar: 1).count
    @babycar_2 = Kuchikomi.where(shop_id: @shop.id).where(babycar: 2).count
    @hirosa_1 = Kuchikomi.where(shop_id: @shop.id).where(hirosa: 1).count
    @hirosa_2 = Kuchikomi.where(shop_id: @shop.id).where(hirosa: 2).count
    @seki_hiroi_1 = Kuchikomi.where(shop_id: @shop.id).where(seki_hiroi: 1).count
    @seki_hiroi_2 = Kuchikomi.where(shop_id: @shop.id).where(seki_hiroi: 2).count
    @suiteru_1 = Kuchikomi.where(shop_id: @shop.id).where(suiteru: 1).count
    @suiteru_2 = Kuchikomi.where(shop_id: @shop.id).where(suiteru: 2).count
    @chusyajo_1 = Kuchikomi.where(shop_id: @shop.id).where(chusyajo: 1).count
    @chusyajo_2 = Kuchikomi.where(shop_id: @shop.id).where(chusyajo: 2).count
    @ekitika_1 = Kuchikomi.where(shop_id: @shop.id).where(ekitika: 1).count
    @ekitika_2 = Kuchikomi.where(shop_id: @shop.id).where(ekitika: 2).count
    @access_1 = Kuchikomi.where(shop_id: @shop.id).where(access: 1).count
    @access_2 = Kuchikomi.where(shop_id: @shop.id).where(access: 2).count
    @kangei_1 = Kuchikomi.where(shop_id: @shop.id).where(kangei: 1).count
    @kangei_2 = Kuchikomi.where(shop_id: @shop.id).where(kangei: 2).count
    @kositu_zasiki_yoyaku_1 = Kuchikomi.where(shop_id: @shop.id).where(kositu_zasiki_yoyaku: 1).count
    @kositu_zasiki_yoyaku_2 = Kuchikomi.where(shop_id: @shop.id).where(kositu_zasiki_yoyaku: 2).count
    @ehon_omocha_1 = Kuchikomi.where(shop_id: @shop.id).where(ehon_omocha: 1).count
    @ehon_omocha_2 = Kuchikomi.where(shop_id: @shop.id).where(ehon_omocha: 2).count
    @epuron_1 = Kuchikomi.where(shop_id: @shop.id).where(epuron: 1).count
    @epuron_2 = Kuchikomi.where(shop_id: @shop.id).where(epuron: 2).count
    @eisei_1 = Kuchikomi.where(shop_id: @shop.id).where(eisei: 1).count
    @eisei_2 = Kuchikomi.where(shop_id: @shop.id).where(eisei: 2).count
    @user_ids_comments = Kuchikomi.where(shop_id: @shop.id).select('user_id', 'comment')


  end


  #ショップ一覧画面から口コミするをクリックでここに来る（2回目以降の口コミ投稿の場合）→ kuchikomi.html.erbへ
  def kuchikomi
    @shop = Shop.find(params[:id])              #URLパラメータにshopのidが入ってるので、それで@shopを生成
    @kuchikomi = Kuchikomi.new                  #kuchikomiのインスタンスを生成
    @kuchikomi.shop_id = @shop.id               #ここでショップIDを入れておこう
    puts '◆kuchikomi  shop_id'
    puts @kuchikomi.shop_id
  end
  
  #ここで口コミ投稿させる
  def kuchikomi_post
    @kuchikomi = Kuchikomi.new(kuchikomi_params) #POSTデータをストロングパラメータに渡してインスタンス生成

    @shop = Shop.find(@kuchikomi.shop_id)        #ジャンプ先指定のためにショップのインスタンスも生成。　ルーティングによりparams[:id]でもshop idがとれる。どっちでもいい。
  
=begin
    @shop = Shop.find(params[:id])              #URLにあるshopのidをとってインスタンス生成 ジャンプ先指定のため
    @kuchikomi.shop_id = @shop.id
=end

    if @kuchikomi.save
      flash[:success] = '口コミ が正常に投稿されました'
      redirect_to @shop
    else
      flash.now[:danger] = '口コミ が投稿されませんでした'
      render :kuchikomi                          #kuchikomi.html.erbへ飛ばす
    end

  end

  private

  # ストロングパラメーター　POSTされたデータのチェック
  def kuchikomi_params
    params.require(:kuchikomi).permit(:shop_id, :kozure_ok, :familymuke, :nyuji_ok, :nigiyaka, :smoking, :kids_chair, :kids_menu, :kids_syokki,
                                      :low_allergy_food, :motikomi, :zasiki, :kositu, :junyusitu, :omutu_space, :kids_space, :babycar, 
                                      :hirosa, :seki_hiroi, :suiteru, :chusyajo, :ekitika, :access, :kangei, :kositu_zasiki_yoyaku, :ehon_omocha, :epuron, :eisei, :comment)
  end

end
