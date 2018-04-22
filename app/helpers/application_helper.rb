module ApplicationHelper
  
  def page_title
    title = "子連れでランチしよう！パパママ口コミサイト - KoLuKu" #トップページタイトル
    title = @page_title + " | " + title if @page_title
    title
  end
  
  def header_message

    if request.path == '/' #トップページなら
      hmessage = '<h1 class="toph1">子連れランチがしやすい飲食店口コミシェアサイト！ディナーもね♪</h1>'
    else
      hmessage = '子連れで入りやすい飲食店口コミシェアサイト'
    end
    hmessage
  end
  
end
