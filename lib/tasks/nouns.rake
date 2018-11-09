namespace :nouns do
  desc "名詞辞書CSVを生成する"
  task :generate do
    csv_data = CSV.read(Rails.root.join('db', 'data', 'nouns', 'from.csv'), headers: false)
    corrections = CSV.read(Rails.root.join('db', 'data', 'nouns', 'corrections.csv'), headers: false)
    corrections = corrections.to_h
    to_path = Rails.root.join('db', 'data', 'nouns', 'to.csv')

    nm = Natto::MeCab.new
    results = csv_data.map do |data|
      items = nm.parse(data[1])
      items = items.split("\n")
      text = items.map do |item|
        item = item.split(",")
        item[8]
      end.join
      romaji = Romaji.kana2romaji(text)
      result = romaji
      if correction = corrections[romaji]
        result = correction
      end
      result.delete!('-')
      result.gsub!(/[^a-zA-z0-9!"#$%&'()\*\+:;<=>?@\[\\\]^_`{|}~ａ-ｚＡ-Ｚ０-９！”＃＄％＆’（）＊＋－．，／：；＜＝＞？＠［￥］「」＾＿‘｛｜｝～]/, '')
      data[2] = result
      data[3] = text
      data
    end
    results.reject!{|result| result[1].match(/\p{katakana}/) }
    CSV.open(to_path,'w') do |file|
      results.each do |result|
        file << [result[0],result[1],result[2]]
        # file << [result[0],result[3],result[2]]
      end
    end
  end

  task :be_snake do
    csv_data = CSV.read(Rails.root.join('db', 'data', 'csv', '案内用データ - 案内先（形態素解析）.csv'), headers: true)
    to_path = Rails.root.join('db', 'data', 'nouns', 'snake', 'to.csv')

    results = csv_data.map do |data|
      if name_en = data['英語名（name_en）']
        name_en.downcase!
        name_en.gsub!(/\(|\)|\:|"|\.|\//, '')
        name_en.gsub!(/\-| |,/, '_')
        name_en.gsub!(/é/, 'e')
        name_en.gsub!(/__+/, '_')
      end
      data['英語名（name_en）'] = name_en
      if name_ja = data['案内先名（name_ja）']
        name_ja.gsub!(/（.+）/, '')
      end
      data
    end

    items = results.map do |result|
      item = []
      item << [result['案内先名（name_ja）'],result['英語名（name_en）']]
      keywords = result['キーワード'].split(',')
      keywords.each do |word|
        unless word == result['案内先名（name_ja）']
          item << [word, result['英語名（name_en）']]
        end
      end
      item
      # file << [result[0],result[3],result[2]]
    end.flatten(1).uniq

    CSV.open(to_path,'w') do |file|
      items.each do |item|
        file << item
      end
    end
  end
end
