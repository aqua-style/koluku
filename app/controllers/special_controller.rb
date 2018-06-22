class SpecialController < ApplicationController
  
  def ikebukuro
    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '【池袋】子連れで食事、赤ちゃんが喜ぶカフェ/居酒屋/レストラン24店舗'
  end
  
end