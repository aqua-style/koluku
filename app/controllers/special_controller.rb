class SpecialController < ApplicationController
  
  def ikebukuro
    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '【池袋】子連れで食事、赤ちゃんが喜ぶカフェ/居酒屋/レストラン24店舗'
  end

  def tokyoeki
    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '【東京駅】子連れで食事、赤ちゃんが喜ぶカフェ/居酒屋/レストラン9店舗'
  end
  
  def shibuya
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '【渋谷駅】子連れで食事、赤ちゃんが喜ぶカフェ/居酒屋/レストラン21店舗'
  end

  def nikohapi_ikebukuro
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb 'わんわん・うーたんと遊べる！にこはぴきっず池袋をレポします'
  end


end