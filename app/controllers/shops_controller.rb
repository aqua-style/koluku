require 'net/http'
require 'uri'
require 'json'
class ShopsController < ApplicationController


 
  #パンくずリストのTOP
  #add_breadcrumb 'KoLuKu', '/'
  
  

  ###########################################################################################
  def index #ショップの一覧表示
    #@shops = Shop.all

#    @keyword = params[:keyword] #検索KWを取る
    @area = params[:area]
    @tenpo_genre = params[:tenpo_genre]

    @option = '1' #初期値1
    @option = params[:option] if params[:option].present? #option:0ならDBのみ検索 option:1ならDB&Yahoo検索 ｜TOPもナビバー検索もデフォルトは1　内部リンクは0のメニューもある
    @option = '0' if params[:kodawari].present? #こだわり検索のときはDB内検索にする


    @keyword = @area + ' ' + @tenpo_genre
    puts @keyword
    puts '検索オプション' + @option.to_s
    
    if @keyword.present?
      
      #キーワードからDB内を探す
      @shops_db = []
      
=begin
      if @area.present? && !@tenpo_genre.present? then #areaしか入ってないなら
        @shops_db = Shop.where("(y_address like ?) OR (y_moyorieki like ?)", "\%#{@area}\%", "\%#{@area}\%")#住所か駅カラムに含まれるか
      elsif @area.present? && @tenpo_genre.present? then #areaとtenpo_genreが入っているなら
        @shops_db = Shop.where("((y_address like ?) OR (y_moyorieki like ?)) AND ((name like ?) OR (y_gyosyu like ?))", "\%#{@area}\%", "\%#{@area}\%", "\%#{@tenpo_genre}\%", "\%#{@tenpo_genre}\%")
      elsif !@area.present? && @tenpo_genre.present? then #tenpo_genreしか入ってないなら
        @shops_db = Shop.where("(name like ?) OR (y_gyosyu like ?)", "\%#{@tenpo_genre}\%", "\%#{@tenpo_genre}\%")
      end
=end

      if @area.present? && !@tenpo_genre.present? then #areaしか入ってないなら
        if @area.include?("駅") #駅がはいってるなら駅検索
          @shops_db = Shop.where("(y_moyorieki like ?)", "\%#{@area}\%")
        else  #そうでなければ住所検索
          @shops_db = Shop.where("(y_address like ?)", "\%#{@area}\%")
        end
      elsif @area.present? && @tenpo_genre.present? then #areaとtenpo_genreが入っているなら
        if @area.include?("駅")
          @shops_db = Shop.where("(y_moyorieki like ?) AND ((name like ?) OR (y_gyosyu like ?))", "\%#{@area}\%", "\%#{@tenpo_genre}\%", "\%#{@tenpo_genre}\%")
        else
          @shops_db = Shop.where("(y_address like ?) AND ((name like ?) OR (y_gyosyu like ?))", "\%#{@area}\%", "\%#{@tenpo_genre}\%", "\%#{@tenpo_genre}\%")
        end
      elsif !@area.present? && @tenpo_genre.present? then #tenpo_genreしか入ってないなら
        @shops_db = Shop.where("(name like ?) OR (y_gyosyu like ?)", "\%#{@tenpo_genre}\%", "\%#{@tenpo_genre}\%")
      end

      #こだわり検索の条件を＆でつなげる
      if params[:kodawari].present?
        params[:kodawari].each do |key, value|
          next unless Shop.column_names.include?(key)
          @shops_db = @shops_db.where("#{key} >= 1") if value.present?
        end
      end

      
      
      #kuchikomisの多い順から並び替えして配列に変換おく
      #@shops_db_ranking = @shops_db.sort{|a, b| b.kuchikomis.size <=> a.kuchikomis.size} if @shops_db.present?
      #puts '◆DBから取った口コミ順の店舗リスト'
      #puts @shops_db_ranking.inspect


      #######ここからYahoo検索
      if @option == '1'

        #Yahoo APIを使って探す
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
        
          chofuku_gid = []
          #if @shops_db_ranking.present?
          #  @shops_db_ranking.each do |shop_db_ranking|
          if @shops_db.present?
            @shops_db.each do |shop_db|
              chofuku_gid.push(shop_db.y_gid)
              puts '◆DB内の店舗名とGID→' + shop_db.name + ':' + shop_db.y_gid
            end
          end
          
          @y_shops = []
  
          @features.each_with_index do |feature,i| #@features配列から1個1個とりだしてshopのインスタンスを生成していく
  
            if chofuku_gid.include?(feature['Gid']) #すでにGidがあるなら重複なのでインスタンスを生成しない
              puts 'DBと重複あり: ' + feature['Name'] + ':' + feature['Gid']
            else
              chofuku_gid.push(feature['Gid'])
              
              #このタイミングでGidでshopsテーブルに問いかけ、ある？あるならインスタンス生成みたいな
              tmp_shop = Shop.find_by(y_gid: feature['Gid'])
              if tmp_shop.present?
                #@shops_db_ranking.push(tmp_shop)
                @shops_db += [tmp_shop]
                next #このifを抜けて次のループへ行きたい
              end
  
              ####ここからデータチェック####
              unless feature['Property'].present?  #propertyがカラなら
                uid = nil
                address = nil
                image_url = nil
              else                                  #propertyがあるなら
                uid = feature['Property']['Uid']
                address = feature['Property']['Address']
                image_url = feature['Property']['LeadImage']
                
                #なかのstationがあるかチェック
                unless feature['Property']['Station'].present? #nil.['Railway']とやるとエラーでるからチェックしないといけない #stationがカラなら
                	eki = nil
                else  #stationがあるなら
#                	eki = feature['Property']['Station'][0]['Railway'] + "　" + feature['Property']['Station'][0]['Name']+"駅 徒歩" + feature['Property']['Station'][0]['Time'] + "分"
#                end
                  begin
                    unless feature['Property']['Station'][0]['Railway'].present? #railwayが空なら
                      eki = feature['Property']['Station'][0]['Name']+"駅 徒歩" + feature['Property']['Station'][0]['Time'] + "分"
                    else
                    	eki = feature['Property']['Station'][0]['Railway'] + "　" + feature['Property']['Station'][0]['Name']+"駅 徒歩" + feature['Property']['Station'][0]['Time'] + "分"
                  	end
                  rescue => e
                      puts 'stationでエラーでた'
                      eki = nil
                  end
                end


=begin 20180427
                #なかの業種があるかチェック
                if feature['Property']['Genre'] && feature['Property']['Genre'][0]
                  gyosyu = get_gyosyumei(feature['Property']['Genre'][0]['Code'])
                  puts '該当する業種がありませんでした:' + feature['Property']['Genre'][0]['Code'] unless gyosyu
                else
                  gyosyu = nil
                end
=end
                #なかの業種があるかチェック
                if feature['Property']['Genre'].present?
                  gyosyus = ""
                  feature['Property']['Genre'].each do |g|
                    puts '業種コード：' + g['Code']
                    gyosyu = get_gyosyumei(g['Code'])
                    puts '該当する業種がありませんでした:' + g['Code'] unless gyosyu
                    gyosyus += "・" + gyosyu if gyosyu
                  end
                else
                  gyosyus = nil
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
              
              @y_shops.push(
                Shop.new(
                name: feature['Name'],
                y_id: feature['Id'], 
                y_gid: feature['Gid'], 
                y_uid: uid,                            #feature['Property']['Uid'], 
                y_ido: ido,                            #feature['Geometry']['Coordinates'].split(",")[1], 
                y_keido: keido,                        #feature['Geometry']['Coordinates'].split(",")[0], 
                y_address: address,                    #feature['Property']['Address'], 
                y_moyorieki: eki,                      #feature['Property']['Station'][0]['Railway'] + "　" + feature['Property']['Station'][0]['Name']+"駅 徒歩" + feature['Property']['Station'][0]['Time'] + "分"
                y_leadimage: image_url,                #feature['Property']['LeadImage']
                y_gyosyu: gyosyus,
                )
              )
            end #if chofuku_gid.include?(feature['Gid'])
          end #ループ
          
          puts '◆DBから生成した店舗リスト'
          puts  @shops_db.inspect

          puts '◆検索から生成した店舗リスト'
          puts @y_shops.inspect

        end   #@feature.present?
      end   #if @option == 1



      #kuchikomisの多い順からもう１度並び替えしておく(ヽ´ω`)
      @shops_db_ranking = @shops_db.sort{|a, b| b.kuchikomis.size <=> a.kuchikomis.size} if @shops_db.present?
      puts '◆DBから生成した口コミ順の店舗リスト'
      puts @shops_db_ranking.inspect
      
      
      hoge = []
      if @shops_db_ranking.present? 
        hoge.concat(@shops_db_ranking)
      end
      if @y_shops.present?
        hoge.concat(@y_shops)
      end
      
      
      @kensu = hoge.length
      @shops = Kaminari.paginate_array(hoge).page(params[:page]).per(30)
      


      
=begin
      if @shops_db_ranking && @y_shops then     #どっちもあるなら
        @shops = @shops_db_ranking + @y_shops   #DBから取得した店舗の後ろに、Yahooから取得した店舗を追加
      elsif @shops_db_ranking || @y_shops then  #どっちかしかないなら
        @shops = (@shops_db_ranking || @y_shops)
      else  #どっちもないなら
        @shops = nil
      end
=end
      puts '◆DBと検索から生成したshopリスト'
      puts @shops.inspect if @shops.present?


      #条件検索時のタイトル設定
      #タイトルに出す項目はKWがある12項目に絞り、上から優先順位を付けて3つまでとする
      #h1タイトルは個数は何個でもよい
      jcheck = Array.new(12)
      jtitle = ""
      jh1 = ""
      jnum = 0
      if params[:kodawari].present?
        params[:kodawari].each do |key, value|
          if value.present?
            puts 'value:' + value.to_s + ' key:' + key
            case key
              when 'nyuji_ok' then      jcheck[0] = 1
              when 'kids_menu' then     jcheck[1] = 1
              when 'omutu_space' then   jcheck[2] = 1
              when 'zasiki' then        jcheck[3] = 1
              when 'motikomi' then      jcheck[4] = 1
              when 'babycar' then       jcheck[5] = 1
              when 'kositu' then        jcheck[6] = 1
              when 'low_allergy_food' then                jcheck[7] = 1
              when 'junyusitu' then     jcheck[8] = 1
              when 'kids_space' then    jcheck[9] = 1
              when 'chusyajo' then      jcheck[10] = 1
              when 'kangei' then        jcheck[11] = 1
            end
          end
        end
      end
      
      if jcheck[0] == 1
              jtitle << "赤ちゃんOK / "
              jh1  << "赤ちゃんOK / "
              jnum += 1
      end
      if jcheck[1] == 1
              jtitle << "キッズメニュー / "
              jh1 << "キッズメニュー / "
              jnum += 1
      end
      if jcheck[2] == 1
              jtitle << "おむつ台 / "
              jh1 << "おむつ台 / "
              jnum += 1
      end
      if jcheck[3] == 1
                jh1 << "座敷 / "
                if jnum < 3
                  jtitle << "座敷 / "
                  jnum += 1
                end
      end
      if jcheck[4] == 1
                jh1 << "離乳食持ち込み / "
                if jnum < 3
                  jtitle << "離乳食持ち込み / "
                  jnum += 1
                end
      end
      if jcheck[5] == 1
                jh1 << "ベビーカー入店ok / "
                if jnum < 3
                  jtitle << "ベビーカー入店ok / "
                  jnum += 1
                end
      end
      if jcheck[6] == 1
                jh1 << "個室 / "
                if jnum < 3
                  jtitle << "個室 / "
                  jnum += 1
                end
      end
      if jcheck[7] == 1
                jh1 << "低アレルギー / "
                if jnum < 3
                  jtitle << "低アレルギー / "
                  jnum += 1
                end
      end
      if jcheck[8] == 1
                jh1 << "授乳室 / "
                if jnum < 3
                  jtitle << "授乳室 / "
                  jnum += 1
                end
      end
      if jcheck[9] == 1
                jh1 << "キッズスペース / "
                if jnum < 3
                  jtitle << "キッズスペース / "
                  jnum += 1
                end
      end
      if jcheck[10] == 1
                jh1 << "駐車場 / "
                if jnum < 3
                  jtitle << "駐車場 / "
                  jnum += 1
                end
      end
      if jcheck[11] == 1
                jh1 << "子連れ歓迎 / "
                if jnum < 3
                  jtitle << "子連れ歓迎 / "
                  jnum += 1
                end
      end


      #記事タイトルとH1生成
      @page_title = ''
      @h1title = ''
      if @area.present? && !@tenpo_genre.present?
        @page_title = @area + 'で子連れランチ・ディナーOKな飲食店口コミ情報'
        @h1title = @area + 'で子連れランチ・ディナーOKな飲食店'
      elsif @area.present? && @tenpo_genre.present?
        @page_title = @area + '×' + @tenpo_genre + '　子連れOK飲食店の口コミ情報'
        @h1title = @area + '×' + @tenpo_genre + '　子連れOK飲食店'
      elsif !@area.present? && @tenpo_genre.present?
        @page_title = @tenpo_genre + 'の子連れOK飲食店の口コミ情報'
        @h1title = @tenpo_genre + 'の子連れOK飲食店'
      end
      
      #条件タイトルを前につなげる
      if jtitle.present?
        @page_title = jtitle + @page_title
        @h1title = jh1 + @h1title
      end
      
      puts @page_title



      #パンくずリスト
      pref = get_pref2(@area)
      add_breadcrumb 'こるく TOP', '/'
      add_breadcrumb pref, shops_path + '?area=' + pref + '&tenpo_genre=&option=0' if pref #◯◯市区町村のときは県もパンくずに入れる
      pankuzu_title = ''
      if @area.present?
        pankuzu_title = @area + '周辺'
        if @tenpo_genre.present?
          pankuzu_title.concat('の' + @tenpo_genre)
        end
      elsif @tenpo_genre.present?
        pankuzu_title.concat(@tenpo_genre)
      end
      add_breadcrumb pankuzu_title if pankuzu_title.present?


    end

  end

  ###########################################################################################
  #ショップの一覧画面から初めて口コミ投稿されるときにこのアクションにくる→new.html.erbで投稿画面のformを出す→kuchikomi#createへ
  def new
    puts '■newきた'    
    
=begin これいらなくね
    #index.html.erbからURLクエリで送られてきた店舗情報を展開してハッシュに入れる、これを次のnew画面にもっていく
    @hash = {}
    request.query_parameters.each do |key, value|
      @hash[key] = value.to_s
    end
    puts request.query_parameters
    puts @hash
    @hash.symbolize_keys! #文字列のKEYをシンボル化
=end

=begin
    #ハッシュに入れてnew.html.erbに渡してたけど、@shopを作って持っていけばいいことに気づいた
    @hash = request.query_parameters
    puts @hash
=end

    @kuchikomi = Kuchikomi.new
    @shop = Shop.new(request.query_parameters)
    puts @shop.attributes

  end

  ###########################################################################################
  #ショップのnew.html.erb画面からformで投稿されたらここにくる。ここで店保存、最初の口コミ保存を行う。
  def create
    puts '◆createきた'
  
    #このなかでaccepts_nested_attributes_for をつかう
    #使い方がわからんから諦めよう
    
    @shop = Shop.new(shop_params)
    #@kuchikomi = @shop.kuchikomis.build(kuchikomi_params) buildはshopがDBにあってIDを渡すからDBにない段階でやっちゃダメ
    @kuchikomi = Kuchikomi.new(kuchikomi_params)

    puts 'shop生成されてる？'
    puts @shop.inspect

    if @shop.save
      @kuchikomi = @shop.kuchikomis.build(kuchikomi_params)  #shopのDB保存が成功してるので改めてkuchikomiを生成
      puts '【新規shopをDBへ保存】shop_idは'
      puts @kuchikomi.shop_id #ここでショップIDが入ってるか確認しよう

      if @kuchikomi.save
        
        #口コミが入ったので集計してshopに持たせて再save
        @shop = set_shop_data(@shop.id)
        @shop.save
              
        flash[:tokosuccess] = '口コミを投稿しました。ご協力に感謝します。'
        redirect_to @shop
      else
        flash.now[:danger] = '何らかの理由によりこの店舗への口コミができません　shop-create-error1'
        render :kuchikomi #店舗はDBに保存してあるのでこっちを表示
      end
    else
      flash.now[:danger] = '何らかの理由によりこの店舗への口コミができません　shop-create-error2'
      render :new  #店舗DB保存に失敗してるので、newに飛ばしたい
    end


  end

  ###########################################################################################
  #ショップ一覧画面からショップの口コミ詳細をクリックしたらここに来て→show.html.erbを表示
  def show 
    @shop = Shop.find(params[:id])

    #画像の生成とページネーション
    if request.smart_phone? || request.tablet?
      puts 'スマホかタブレット'
      @shop_photos = @shop.shop_photos.page(params[:page]).per(6)
    else
      puts 'PCアクセス'
      @shop_photos = @shop.shop_photos.page(params[:page]).per(8)
    end


    puts @shop_photos.inspect 

    
    #ここでカウント
    @kozure_ok_1 = Kuchikomi.where(shop_id: @shop.id).where(kozure_ok: 1).count #子連れしやすいの数
    @kozure_ok_2 = Kuchikomi.where(shop_id: @shop.id).where(kozure_ok: 2).count #子連れしにくいの数
    @nyuji_ok_1 = Kuchikomi.where(shop_id: @shop.id).where(nyuji_ok: 1).count
    @nyuji_ok_2 = Kuchikomi.where(shop_id: @shop.id).where(nyuji_ok: 2).count
    @smoking_1 = Kuchikomi.where(shop_id: @shop.id).where(smoking: 1).count     #禁煙の数
    @smoking_2 = Kuchikomi.where(shop_id: @shop.id).where(smoking: 2).count     #分煙の数
    @smoking_3 = Kuchikomi.where(shop_id: @shop.id).where(smoking: 3).count     #喫煙の数
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

    #口コミ投稿したユーザーのuser_idとnicknameとcommentとimageとupdated_atとをとりたい
    #こんなようなことをやりたい↓
    #SELECT users.id, users.nickname,kuchikomis.comment FROM kuchikomis JOIN users ON kuchikomis.user_id = users.id WHERE kuchikomis.shop_id = 2; 
    #これでできる？↓
    @user_comment_infos = {}
    kuchikomis = Shop.find(@shop.id).kuchikomis.order('created_at DESC')
    
    @user_comment_infos = Array.new(kuchikomis.count){{}} #取得したレコード数で配列とハッシュを初期化
    
    kuchikomis.each_with_index do |kuchikomi,index|
      user_id = nil
      nickname = nil
      image = nil
      if kuchikomi.user.present?              #userがいるなら
        user_id = kuchikomi.user.id
        nickname = kuchikomi.user.nickname
        image = kuchikomi.user.image.thumb30.url
      end
  	  @user_comment_infos[index] = {           #ただの2次元ハッシュ　これをviewで表示させたい ここarray.pushでやったほうがよくない？
  	      :user_id => user_id,
  	    	:nickname => nickname,
  	    	:image => image,
  	    	:comment => kuchikomi.comment,
  	    	:updated_at => kuchikomi.updated_at,
       }
       
    end
    
    
    #記事タイトル生成
    @page_title = @shop.name + 'って子ども赤ちゃんと入りやすい？'
    
    
    
    #パンくずリスト
    pref = get_pref(@shop.y_address)
    city = get_city(pref, @shop.y_address)

    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb pref, shops_path + '?area=' + pref + '&tenpo_genre=&option=0' if pref #shops?area=柏駅&tenpo_genre=&commit=検索&option=0 こういうURLを作りたい
    add_breadcrumb city, shops_path + '?area=' + city + '&tenpo_genre=&option=0' if city
    add_breadcrumb @shop.name
    
    render layout: false #application.html.erbを適用したくない
  end

  ###########################################################################################
  #ショップ一覧画面から口コミするをクリックでここに来る（2回目以降の口コミ投稿の場合）→ kuchikomi.html.erbへ
  def kuchikomi
    puts 'ショップIDは' + params[:id].to_s
    @shop = Shop.find(params[:id])              #URLパラメータにshopのidが入ってるので、それで@shopを生成
    @kuchikomi = Kuchikomi.new                  #kuchikomiのインスタンスを生成
    @kuchikomi.shop_id = @shop.id               #ここでショップIDを入れておこう
    puts '◆kuchikomi  shop_id'
    puts @kuchikomi.shop_id

    #画像の生成とページネーション
    if request.smart_phone? || request.tablet?
      puts 'スマホかタブレット'
      @shop_photo_view = @shop.shop_photos.page(params[:page]).per(6)
    else
      puts 'PCアクセス'
      @shop_photo_view = @shop.shop_photos.page(params[:page]).per(8)
    end
    
    @shop_photo = ShopPhoto.new                 #アップロード用
    
    @page_title = @shop.name + 'の口コミを投稿'
    
    render layout: false #application.html.erbを適用したくない
  end


  ###########################################################################################
  #ここで口コミ投稿させる
  def kuchikomi_post
    @kuchikomi = Kuchikomi.new(kuchikomi_params) #POSTデータをストロングパラメータに渡してインスタンス生成
   
    @shop = Shop.find(@kuchikomi.shop_id)        #ジャンプ先指定のためにショップのインスタンスも生成。　ルーティングによりparams[:id]でもshop idがとれる。どっちでもいい。
  
=begin
    @shop = Shop.find(params[:id])              #URLにあるshopのidをとってインスタンス生成 ジャンプ先指定のため
    @kuchikomi.shop_id = @shop.id
=end

    #@kuchikomi.shop_id = '' #エラーテスト
    if @kuchikomi.save
      #flash[:success] = '投稿ありがとうございました！'
      flash[:tokosuccess] = '投稿ありがとうございました！'

      #ここでshopテーブルに入れるデータの集計とUpdate
      @shop = set_shop_data(@shop.id)
      @shop.save
      
      redirect_to @shop
    else
      flash.now[:danger] = '口コミ が投稿されませんでした'
      render :kuchikomi                          #kuchikomi.html.erbへ飛ばす
    end

  end
  
  #############################################################################################
  #これは管理者がショップを編集するメソッド
#  def mng_hensyu
  def mng_shop_hensyu

    @shop = Shop.find(params[:shop_id].to_i)

    if @shop.update(shop_params)
      flash[:success] = 'お店の紹介文を編集しました。'
    else
      flash[:danger] = 'お店の紹介文の編集に失敗しました。'
    end
    redirect_back(fallback_location: root_path)
    
  end
  

  private

  #口コミを集計してshopテーブルに入れるメソッド
  def set_shop_data(shopid)
    shop = Shop.find(shopid)
    kozure_ok_1 = Kuchikomi.where(shop_id: shop.id).where(kozure_ok: 1).count
    kozure_ok_2 = Kuchikomi.where(shop_id: shop.id).where(kozure_ok: 2).count
    nyuji_ok_1 = Kuchikomi.where(shop_id: shop.id).where(nyuji_ok: 1).count
    nyuji_ok_2 = Kuchikomi.where(shop_id: shop.id).where(nyuji_ok: 2).count
    smoking_1 = Kuchikomi.where(shop_id: shop.id).where(smoking: 1).count
    smoking_2 = Kuchikomi.where(shop_id: shop.id).where(smoking: 2).count
    smoking_3 = Kuchikomi.where(shop_id: shop.id).where(smoking: 3).count
    familymuke_1 = Kuchikomi.where(shop_id: shop.id).where(familymuke: 1).count
    familymuke_2 = Kuchikomi.where(shop_id: shop.id).where(familymuke: 2).count
    nigiyaka_1 = Kuchikomi.where(shop_id: shop.id).where(nigiyaka: 1).count
    nigiyaka_2 = Kuchikomi.where(shop_id: shop.id).where(nigiyaka: 2).count
    kids_chair_1 = Kuchikomi.where(shop_id: shop.id).where(kids_chair: 1).count
    kids_chair_2 = Kuchikomi.where(shop_id: shop.id).where(kids_chair: 2).count
    kids_menu_1 = Kuchikomi.where(shop_id: shop.id).where(kids_menu: 1).count
    kids_menu_2 = Kuchikomi.where(shop_id: shop.id).where(kids_menu: 2).count
    kids_syokki_1 = Kuchikomi.where(shop_id: shop.id).where(kids_syokki: 1).count
    kids_syokki_2 = Kuchikomi.where(shop_id: shop.id).where(kids_syokki: 2).count
    low_allergy_food_1 = Kuchikomi.where(shop_id: shop.id).where(low_allergy_food: 1).count
    low_allergy_food_2 = Kuchikomi.where(shop_id: shop.id).where(low_allergy_food: 2).count
    motikomi_1 = Kuchikomi.where(shop_id: shop.id).where(motikomi: 1).count
    motikomi_2 = Kuchikomi.where(shop_id: shop.id).where(motikomi: 2).count
    zasiki_1 = Kuchikomi.where(shop_id: shop.id).where(zasiki: 1).count
    zasiki_2 = Kuchikomi.where(shop_id: shop.id).where(zasiki: 2).count
    kositu_1 = Kuchikomi.where(shop_id: shop.id).where(kositu: 1).count
    kositu_2 = Kuchikomi.where(shop_id: shop.id).where(kositu: 2).count
    junyusitu_1 = Kuchikomi.where(shop_id: shop.id).where(junyusitu: 1).count
    junyusitu_2 = Kuchikomi.where(shop_id: shop.id).where(junyusitu: 2).count
    omutu_space_1 = Kuchikomi.where(shop_id: shop.id).where(omutu_space: 1).count
    omutu_space_2 = Kuchikomi.where(shop_id: shop.id).where(omutu_space: 2).count
    kids_space_1 = Kuchikomi.where(shop_id: shop.id).where(kids_space: 1).count
    kids_space_2 = Kuchikomi.where(shop_id: shop.id).where(kids_space: 2).count
    babycar_1 = Kuchikomi.where(shop_id: shop.id).where(babycar: 1).count
    babycar_2 = Kuchikomi.where(shop_id: shop.id).where(babycar: 2).count
    hirosa_1 = Kuchikomi.where(shop_id: shop.id).where(hirosa: 1).count
    hirosa_2 = Kuchikomi.where(shop_id: shop.id).where(hirosa: 2).count
    seki_hiroi_1 = Kuchikomi.where(shop_id: shop.id).where(seki_hiroi: 1).count
    seki_hiroi_2 = Kuchikomi.where(shop_id: shop.id).where(seki_hiroi: 2).count
    suiteru_1 = Kuchikomi.where(shop_id: shop.id).where(suiteru: 1).count
    suiteru_2 = Kuchikomi.where(shop_id: shop.id).where(suiteru: 2).count
    chusyajo_1 = Kuchikomi.where(shop_id: shop.id).where(chusyajo: 1).count
    chusyajo_2 = Kuchikomi.where(shop_id: shop.id).where(chusyajo: 2).count
    ekitika_1 = Kuchikomi.where(shop_id: shop.id).where(ekitika: 1).count
    ekitika_2 = Kuchikomi.where(shop_id: shop.id).where(ekitika: 2).count
    access_1 = Kuchikomi.where(shop_id: shop.id).where(access: 1).count
    access_2 = Kuchikomi.where(shop_id: shop.id).where(access: 2).count
    kangei_1 = Kuchikomi.where(shop_id: shop.id).where(kangei: 1).count
    kangei_2 = Kuchikomi.where(shop_id: shop.id).where(kangei: 2).count
    kositu_zasiki_yoyaku_1 = Kuchikomi.where(shop_id: shop.id).where(kositu_zasiki_yoyaku: 1).count
    kositu_zasiki_yoyaku_2 = Kuchikomi.where(shop_id: shop.id).where(kositu_zasiki_yoyaku: 2).count
    ehon_omocha_1 = Kuchikomi.where(shop_id: shop.id).where(ehon_omocha: 1).count
    ehon_omocha_2 = Kuchikomi.where(shop_id: shop.id).where(ehon_omocha: 2).count
    epuron_1 = Kuchikomi.where(shop_id: shop.id).where(epuron: 1).count
    epuron_2 = Kuchikomi.where(shop_id: shop.id).where(epuron: 2).count
    eisei_1 = Kuchikomi.where(shop_id: shop.id).where(eisei: 1).count
    eisei_2 = Kuchikomi.where(shop_id: shop.id).where(eisei: 2).count

    shop.kozure_ok = kozure_ok_1 - kozure_ok_2
    shop.nyuji_ok = nyuji_ok_1 - nyuji_ok_2
    shop.smoking = (smoking_1 + smoking_2) - smoking_3
    shop.familymuke = familymuke_1 - familymuke_2
    shop.nigiyaka = nigiyaka_1 - nigiyaka_2
    shop.kids_chair = kids_chair_1 - kids_chair_2
    shop.kids_menu = kids_menu_1 - kids_menu_2
    shop.kids_syokki = kids_syokki_1 - kids_syokki_2
    shop.low_allergy_food = low_allergy_food_1 - low_allergy_food_2
    shop.motikomi = motikomi_1 - motikomi_2
    shop.zasiki = zasiki_1 - zasiki_2
    shop.kositu = kositu_1 - kositu_2
    shop.junyusitu = junyusitu_1 - junyusitu_2
    shop.omutu_space = omutu_space_1 - omutu_space_2
    shop.kids_space = kids_space_1 - kids_space_2
    shop.babycar = babycar_1 - babycar_2
    shop.hirosa = hirosa_1 - hirosa_2
    shop.seki_hiroi = seki_hiroi_1 - seki_hiroi_2
    shop.suiteru = suiteru_1 - suiteru_2
    shop.chusyajo = chusyajo_1 - chusyajo_2
    shop.ekitika = ekitika_1 - ekitika_2
    shop.access = access_1 - access_2
    shop.kangei = kangei_1 - kangei_2
    shop.kositu_zasiki_yoyaku = kositu_zasiki_yoyaku_1 - kositu_zasiki_yoyaku_2
    shop.ehon_omocha = ehon_omocha_1 - ehon_omocha_2
    shop.epuron = epuron_1 - epuron_2
    shop.eisei = eisei_1 - eisei_2
    shop

  end



  # ストロングパラメーター　POSTされたデータのチェック
  def kuchikomi_params
    params.require(:kuchikomi).permit(:shop_id, :user_id, :kozure_ok, :familymuke, :nyuji_ok, :nigiyaka, :smoking, :kids_chair, :kids_menu, :kids_syokki,
                                      :low_allergy_food, :motikomi, :zasiki, :kositu, :junyusitu, :omutu_space, :kids_space, :babycar, 
                                      :hirosa, :seki_hiroi, :suiteru, :chusyajo, :ekitika, :access, :kangei, :kositu_zasiki_yoyaku, :ehon_omocha, :epuron, :eisei, :comment)
  end
  
  # /shops/new.html.erbでPOSTされたショップのデータ群
  def shop_params
    params.require(:shop).permit(:name, :y_address, :y_gid, :y_id, :y_ido, :y_keido, :y_leadimage, :y_moyorieki, :y_uid, :y_gyosyu, :kozure_ok, :nyuji_ok, :smoking, :familymuke, :nigiyaka, :kids_chair, :kids_menu, :kids_syokki, :low_allergy_food, :motikomi, :zasiki, :kositu, :junyusitu, :omutu_space, :kids_space, :babycar, :hirosa, :seki_hiroi, :suiteru, :chusyajo, :ekitika, :access, :kangei, :kositu_zasiki_yoyaku, :ehon_omocha, :epuron, :eisei, :syoukai, )
  end



  @@gyosyu_masta = {
      '0101' => '和食',
      '0102' => '洋食',
      '0103' => 'バイキング',
      '0104' => '中華',
      '0105' => 'アジア料理、エスニック',
      '0106' => 'ラーメン',
      '0107' => 'カレー',
      '0108' => '焼肉、ホルモン、ジンギスカン',
      '0109' => '鍋',
      '0110' => '居酒屋、ビアホール',
      '0111' => '定食、食堂',
      '0112' => '創作料理、無国籍料理',
      '0113' => '自然食、薬膳、オーガニック',
      '0114' => '持ち帰り、宅配',
      '0115' => 'カフェ、喫茶店',
      '0116' => 'コーヒー、茶葉専門店',
      '0117' => 'パン、サンドイッチ',
      '0118' => 'スイーツ',
      '0119' => 'バー',
      '0120' => 'パブ、スナック',
      '0121' => 'ディスコ、クラブハウス',
      '0122' => 'ビアガーデン',
      '0123' => 'ファミレス、ファストフード',
      '0124' => 'パーティー、カラオケ',
      '0125' => '屋形船、クルージング',
      '0126' => 'テーマパークレストラン',
      '0127' => 'オーベルジュ',
      '0128' => 'その他',
      '0101001' => '和食、懐石料理',
      '0101002' => '和食、会席料理',
      '0101003' => '和食、割ぽう',
      '0101004' => '和食、料亭',
      '0101005' => '和食、小料理',
      '0101006' => '和食、精進料理',
      '0101007' => '和食、京料理',
      '0101008' => '和食、豆腐料理',
      '0101009' => '和食、ゆば料理',
      '0101010' => '和食、おばんざい',
      '0101011' => '和食、日本料理',
      '0101012' => '和食、握り寿司',
      '0101013' => '和食、回転寿司',
      '0101014' => '和食、天ぷら、揚げ物',
      '0101015' => '和食、とんかつ',
      '0101016' => '和食、フライ',
      '0101017' => '和食、そば',
      '0101018' => '和食、うどん',
      '0101019' => '和食、味噌煮込みうどん',
      '0101020' => '和食、沖縄そば',
      '0101021' => '和食、すき焼き',
      '0101022' => '和食、しゃぶしゃぶ',
      '0101023' => '和食、うなぎ',
      '0101024' => '和食、どじょう',
      '0101025' => '和食、焼き鳥',
      '0101026' => '和食、串焼き',
      '0101027' => '和食、鳥料理',
      '0101028' => '和食、おでん',
      '0101029' => '和食、お好み焼き、たこ焼き',
      '0101030' => '和食、もんじゃ焼き',
      '0101031' => '和食、丼もの、牛丼、親子丼',
      '0101032' => '和食、沖縄料理',
      '0101033' => '和食、郷土料理',
      '0101034' => '和食、海鮮料理',
      '0101035' => '和食、ふぐ料理',
      '0101036' => '和食、かに料理',
      '0101037' => '和食、すっぽん料理',
      '0101038' => '和食、あんこう料理',
      '0101039' => '和食、川魚料理',
      '0101040' => '和食、牡蠣料理',
      '0101041' => '和食、豚肉料理',
      '0101042' => '和食、牛肉料理',
      '0101043' => '和食、馬肉料理',
      '0101044' => '和食、炭火焼き',
      '0101045' => '和食、鉄板焼き',
      '0101046' => '和食、牛タン料理',
      '0101047' => '和食、もつ料理',
      '0101048' => '和食、釜飯',
      '0101049' => '和食、くじら料理',
      '0101050' => '和食、炉端焼き',
      '0101051' => '和食、野菜料理',
      '0101052' => '和食、にんにく料理',
      '0101053' => '和食、和食（その他）',
      '0102001' => '洋食、ステーキ、ハンバーグ',
      '0102002' => '洋食、パスタ、ピザ',
      '0102003' => '洋食、ハンバーガー',
      '0102004' => '洋食、洋食（その他）',
      '0102005' => '洋食、フランス料理（フレンチ）',
      '0102006' => '洋食、イタリア料理（イタリアン）',
      '0102007' => '洋食、スペイン料理',
      '0102008' => '洋食、ポルトガル料理',
      '0102009' => '洋食、地中海料理',
      '0102010' => '洋食、ドイツ料理',
      '0102011' => '洋食、ロシア料理',
      '0102012' => '洋食、スイス料理',
      '0102013' => '洋食、ベルギー料理',
      '0102014' => '洋食、アメリカ料理',
      '0102015' => '洋食、カリフォルニア料理',
      '0102016' => '洋食、ケイジャン料理',
      '0102017' => '洋食、オセアニア料理',
      '0102018' => '洋食、パシフィックリム料理',
      '0102019' => '洋食、ハワイ料理',
      '0102020' => '洋食、西洋各国料理',
      '0102021' => '洋食、シーフード、オイスターバー',
      '0102022' => '洋食、バーベキュー',
      '0103001' => 'バイキング、バイキング',
      '0104001' => '中華、中華料理',
      '0104002' => '中華、北京料理',
      '0104003' => '中華、上海料理',
      '0104004' => '中華、広東料理',
      '0104005' => '中華、四川料理',
      '0104006' => '中華、台湾料理',
      '0104007' => '中華、香港料理',
      '0104008' => '中華、餃子',
      '0104009' => '中華、飲茶、点心',
      '0105001' => 'アジア料理、エスニック、韓国料理、朝鮮料理',
      '0105002' => 'アジア料理、エスニック、アフリカ料理',
      '0105003' => 'アジア料理、エスニック、タイ料理',
      '0105004' => 'アジア料理、エスニック、ベトナム料理',
      '0105005' => 'アジア料理、エスニック、インドネシア料理',
      '0105006' => 'アジア料理、エスニック、インド料理',
      '0105007' => 'アジア料理、エスニック、ネパール料理',
      '0105008' => 'アジア料理、エスニック、パキスタン料理',
      '0105009' => 'アジア料理、エスニック、スリランカ料理',
      '0105010' => 'アジア料理、エスニック、トルコ料理',
      '0105011' => 'アジア料理、エスニック、中近東料理、アラビア料理',
      '0105012' => 'アジア料理、エスニック、メキシコ料理',
      '0105013' => 'アジア料理、エスニック、ブラジル料理',
      '0105014' => 'アジア料理、エスニック、アジア料理、エスニック（その他）',
      '0106001' => 'ラーメン、ラーメン',
      '0106002' => 'ラーメン、つけ麺',
      '0107001' => 'カレー、カレー',
      '0107002' => 'カレー、スープカレー',
      '0107003' => 'カレー、欧風カレー',
      '0107004' => 'カレー、インドカレー',
      '0107005' => 'カレー、タイカレー',
      '0108001' => '焼肉、ホルモン、ジンギスカン、焼肉',
      '0108002' => '焼肉、ホルモン、ジンギスカン、ジンギスカン',
      '0108003' => '焼肉、ホルモン、ジンギスカン、ホルモン',
      '0109001' => '鍋、鍋料理',
      '0110001' => '居酒屋、ビアホール、和風居酒屋',
      '0110002' => '居酒屋、ビアホール、洋風居酒屋',
      '0110003' => '居酒屋、ビアホール、アジア居酒屋、無国籍居酒屋',
      '0110004' => '居酒屋、ビアホール、立ち飲み居酒屋',
      '0110005' => '居酒屋、ビアホール、ビアホール',
      '0110006' => '居酒屋、ビアホール、ビアレストラン',
      '0111001' => '定食、食堂、定食、食堂',
      '0112001' => '創作料理、無国籍料理、創作料理',
      '0112002' => '創作料理、無国籍料理、無国籍料理',
      '0113001' => '自然食、薬膳、オーガニック、自然食',
      '0113002' => '自然食、薬膳、オーガニック、薬膳',
      '0113003' => '自然食、薬膳、オーガニック、オーガニック',
      '0114001' => '持ち帰り、宅配、持ち帰り専門、弁当',
      '0114002' => '持ち帰り、宅配、配達専門、宅配ピザ',
      '0114003' => '持ち帰り、宅配、仕出し料理',
      '0115001' => 'カフェ、喫茶店、カフェ',
      '0115002' => 'カフェ、喫茶店、喫茶店',
      '0115003' => 'カフェ、喫茶店、カフェバー',
      '0115004' => 'カフェ、喫茶店、インターネットカフェ',
      '0115005' => 'カフェ、喫茶店、シアトルカフェ',
      '0115006' => 'カフェ、喫茶店、複合カフェ',
      '0115007' => 'カフェ、喫茶店、ドッグカフェ',
      '0115008' => 'カフェ、喫茶店、猫カフェ',
      '0115009' => 'カフェ、喫茶店、ギャラリーカフェ',
      '0115010' => 'カフェ、喫茶店、ブックカフェ',
      '0115011' => 'カフェ、喫茶店、マンガ喫茶',
      '0115012' => 'カフェ、喫茶店、軽食',
      '0115013' => 'カフェ、喫茶店、和風喫茶',
      '0115014' => 'カフェ、喫茶店、カラオケ喫茶',
      '0116001' => 'コーヒー、茶葉専門店、コーヒー専門店',
      '0116002' => 'コーヒー、茶葉専門店、紅茶専門店',
      '0116003' => 'コーヒー、茶葉専門店、中国茶専門店',
      '0116004' => 'コーヒー、茶葉専門店、日本茶専門店',
      '0117001' => 'パン、サンドイッチ、ベーカリー',
      '0117002' => 'パン、サンドイッチ、サンドイッチ',
      '0117003' => 'パン、サンドイッチ、ベーグル',
      '0117004' => 'パン、サンドイッチ、ホットドッグ',
      '0117005' => 'パン、サンドイッチ、パン、サンドイッチ（その他）',
      '0118001' => 'スイーツ、洋菓子、ケーキ',
      '0118002' => 'スイーツ、和菓子、甘味処、たい焼き',
      '0118003' => 'スイーツ、中華菓子',
      '0118004' => 'スイーツ、アイスクリーム、クレープ、パフェ',
      '0119001' => 'バー、バー',
      '0119002' => 'バー、ショットバー',
      '0119003' => 'バー、アイリッシュパブ',
      '0119004' => 'バー、ダイニングバー',
      '0119005' => 'バー、バル、バール',
      '0119006' => 'バー、ビアバー',
      '0119007' => 'バー、ワインバー',
      '0119008' => 'バー、焼酎バー',
      '0119009' => 'バー、レストランバー',
      '0119010' => 'バー、ダーツバー',
      '0119011' => 'バー、ゴルフバー',
      '0120001' => 'パブ、スナック、パブ',
      '0120002' => 'パブ、スナック、スナック',
      '0120003' => 'パブ、スナック、クラブ',
      '0120004' => 'パブ、スナック、ラウンジ',
      '0121001' => 'ディスコ、クラブハウス、ディスコ',
      '0121002' => 'ディスコ、クラブハウス、クラブハウス',
      '0122001' => 'ビアガーデン、ビアガーデン',
      '0123001' => 'ファミレス、ファストフード、ファミレス',
      '0123002' => 'ファミレス、ファストフード、ファストフード',
      '0123003' => 'ファミレス、ファストフード、ファストカジュアル',
      '0124001' => 'パーティー、カラオケ、パーティースペース、宴会場',
      '0124002' => 'パーティー、カラオケ、カラオケボックス',
      '0125001' => '屋形船、クルージング、屋形船',
      '0125002' => '屋形船、クルージング、クルージング',
      '0126001' => 'テーマパークレストラン、テーマパークレストラン',
      '0126002' => 'テーマパークレストラン、アミューズメントレストラン',
      '0127001' => 'オーベルジュ、オーベルジュ',
      '0128001' => 'その他、その他',
      }

  def get_gyosyumei(code)
    @@gyosyu_masta[code]
  end

  #住所がどこの都道府県なのかを返すメソッド（パンくず用）
  def get_pref(adr)
    prefs = ['北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県', '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県', '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県', '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県', '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県']
    prefs.each do |p|
      if adr.include?(p)
        return p
      end
    end
    return nil #万が一見つからなければnilを返す
  end
  
  #逆に市から県をとる
  def get_pref2(area)
    cities = City.where(city: area)

    if cities.length == 1
      return cities[0].pref
    elsif cities.length > 1
      #同一名市区町村のとき。どこの県かわからん。
      return nil
    else
      #ヒットしなかったら
      return nil
    end
  end
  
    

  #住所がどこの市区町村なのかを返すメソッド（パンくず用）
  def get_city(pref, adr)
    cities = City.where(pref: pref)
    cities.each do |c|
      if adr.include?(c.city)
        return c.city
      end
    end
    return nil #万が一見つからなければnilを返す
  end
  
end
