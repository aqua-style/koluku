class InfoController < ApplicationController
  def about
    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '当サイトについて'
  end

  def privacy_policy
    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '個人情報保護方針'
  end

  def tokusho
    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '特商法に基づく表示'
  end
  
  def usage

    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '当サイトのご利用の仕方'

  end
  
  def icon
    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb '口コミ項目とアイコンの説明'
  end
  
  def sitemap
    #パンくずリスト
    add_breadcrumb 'こるく TOP', '/'
    add_breadcrumb 'サイトマップ'
  end
  
end
