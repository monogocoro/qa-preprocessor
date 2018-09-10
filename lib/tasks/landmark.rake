require 'open-uri'
require 'nokogiri'

namespace :landmark do
  desc "東京都のランドマーク一覧を取得する"

  task :fetch => :environment do

    # 接続先「じゃらん」
    base_url = "http://www.jalan.net/kankou/130000/page_"

    # 「じゃらん」東京の観光スポット一覧ページの最後のページ数
    last_page_number = 132

    # ページから観光スポット名を取得
    result = (1..last_page_number).map do |count|
      url = base_url + count.to_s + '/?screenId=OUW1701'
      html = open(url) { |f| f.read }
      doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
      lm_names = doc.xpath('//p[contains(@class, "item-name rank-ico-")]/a/text()').map{|i| i.to_s}
    end
    result.flatten!

    # 含めたくない文字列のある項目を除外
    black_list = %w(トヨタレンタリース ニッポンレンタカー 日産レンタカー レンタカー)
    result.reject! do |item|
      black_list.any?{ |m| item.include?(m) }
    end

    # ファイル書き出し
    File.open(Rails.root.join('tmp', 'landkmarks.org.txt'), 'w') { |f| f.puts result }
  end
end
