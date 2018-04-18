module ApplicationHelper
  
  def page_title
    title = "子連れランチ口コミサイト - KoLuKu" #トップページタイトル
    title = @page_title + " | " + title if @page_title
    title
  end
  
  def header_message

    if request.path == '/' #トップページなら
      hmessage = '<h1 class="toph1 m10-l">子連れランチがしやすい飲食店シェアサイト！ディナーもね♪</h1>'
    else
      hmessage = '子連れで入りやすい飲食店シェアサイト'
    end
    hmessage
  end
  
end
