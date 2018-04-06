require 'net/http'
require 'uri'
require 'json'
class ToppagesController < ApplicationController
  def index
  
=begin
Google Places APIのプレイス検索のテスト
  nihongo = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=デニーズ　新宿&key=AIzaSyAiSHbH8XzEEkkT9MZI9qIEEYTIaswebMk&language=ja'
  enc_str = URI.encode nihongo #日本語を%のUTF-8の形にエンコード
  puts nihongo
  puts enc_str
  
  uri = URI.parse(enc_str)
  json = Net::HTTP.get(uri)
  puts json #生のJSON形式
  hairetu = JSON.parse(json) #配列形式に変換
  puts hairetu['results'][0]['name'] + ":" + hairetu['results'][0]['formatted_address']
  puts hairetu['results'][1]['name'] + ":" + hairetu['results'][1]['formatted_address']
  puts hairetu['results'][2]['name'] + ":" + hairetu['results'][2]['formatted_address']
=end


  yquery = 'https://map.yahooapis.jp/search/local/V1/localSearch?output=json&appid=' + ENV['YAHOO_API_KEY'] +  '&sort=match&&query=柏　ラーメン'
  yquery = 'https://map.yahooapis.jp/search/local/V1/localSearch?output=json&appid=' + ENV['YAHOO_API_KEY'] +  '&sort=match&&query=デニーズ　新宿'

  #日本語を%のUTF-8の形にエンコード
  yquery_enc = URI.encode yquery 
  #yquery_esc = URI.escape yquery
  #yquery_erb = ERB::Util.url_encode yquery
  #yquery_cgi = CGI.escape yquery 
  
  #エンコードのテスト
  puts yquery
  puts yquery_enc

=begin
  uri = URI.parse(yquery_enc)
  json = Net::HTTP.get(uri)
  #puts json
  hairetu = JSON.parse(json) #配列形式に変換
  puts hairetu


  #配列からショップ名を取り出す
  @shop1name = hairetu['Feature'][0]['Name'] 
  @shop2name = hairetu['Feature'][1]['Name']
  
  #配列から住所を取り出す
  @shop1addr = hairetu['Feature'][0]['Property']['Address']
  @shop2addr = hairetu['Feature'][1]['Property']['Address']

  puts @shop1name + '　' + @shop1addr
  puts @shop2name + '　' + @shop2addr


  #配列から緯度・軽度をとりだす
  @shop1coor = hairetu['Feature'][0]['Geometry']['Coordinates']
  @shop2coor = hairetu['Feature'][1]['Geometry']['Coordinates']
  
  puts @shop1coor
  puts @shop2coor
  
  @keido1 = @shop1coor.split(",")[0].to_f
  @ido1 = @shop1coor.split(",")[1].to_f
  @keido2 = @shop2coor.split(",")[0].to_f
  @ido2 = @shop2coor.split(",")[1].to_f

  array = [@keido1,@keido2]
  @c_keido = array.inject(0.0){|r,i| r+=i }/array.size
  array = [@ido1,@ido2]
  @c_ido = array.inject(0.0){|r,i| r+=i }/array.size

=end

  end
end
