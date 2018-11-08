require 'csv'

namespace :to_json do
  desc "階段に変更する"
  task :stairs do
    hash = {
      '内' => true,
      '外' => false,
      nil => nil
    }
    types = {
      'エスカレーター' => '1',
      'エレベーター' => '2',
      '階段' => '3',
      nil => nil
    }
    sort_table = %w(B3 B2 P B1 1 2 M3 3 4 M5 5 6 7 M8 8 9 10 11 R 15)

    csv_data = CSV.read(Rails.root.join('db', 'data', 'csv', '案内用データ - stairs.csv'), headers: true)

    File.open(Rails.root.join('db', 'data', 'json', 'stairs.json'), 'w') do |file|
      results = csv_data.map do |data|
        data = data.to_h
        result = {}
        # result['id'] = data['id']
        result['name'] = data['name']
        result['name_en'] = data['name_en']
        result['type'] = types[data['type']]
        result['inside'] = hash[data['inside']]
        result['ingate'] = hash[data['ingate']]
        point_array = data['point'].split(',')
        x = point_array[1]
        y = point_array[2]

        multi_line = data['point'].match(/(\r\n|\n|\r).+/)

        floors = []
        if multi_line
          points = data['point'].split(multi_line[1])
          floors = points.map do |point|
            point = point.split(',')
            floor = point[0].upcase
            {"floor" => floor, "x" => point[1], "y" => point[2], "number" => sort_table.index(floor)}
          end
        else
          items = data['floors'].split(',')
          items << point_array[0]

          floors = items.map do |item|
            if item.include? "-"
              floors = item.split('-')
              floors.map!{|f| f.gsub('F','').upcase}
              first = sort_table.index(floors[0])
              last = sort_table.index(floors[1])
              sort_table[first..last]
            else
              item.gsub('F','').upcase
            end
          end.flatten

          floors.uniq!

          floors.map! do |floor|
            {"floor" => floor, "x" => x, "y" => y, "number" => sort_table.index(floor)}
          end
        end

        size = floors.select{|f| f["number"].blank?}

        floors.sort! {|a, b| a["number"] <=> b["number"]}
        result['end_points'] = floors.map!{|m| m.delete("number"); m}

        # from_endpoint = {
        #   'floor' => from_endpoint_array[0],
        #   'x' => from_endpoint_array[1],
        #   'y' => from_endpoint_array[2]
        # }
        # to_endpoint_array = data['to_endpoint'].split(',')
        # to_endpoint = {
        #   'floor' => to_endpoint_array[0],
        #   'x' => to_endpoint_array[1],
        #   'y' => to_endpoint_array[2]
        # }
        #
        # result['end_points'] = [from_endpoint, to_endpoint]
        result
      end
      file.write(JSON.pretty_generate(results))
    end
  end

  desc "観光情報に変更する"
  task :spots do
    csv_data = CSV.read(Rails.root.join('db', 'data', 'csv', '案内用データ - spots（観光情報）.csv'), headers: true)

    File.open(Rails.root.join('db', 'data', 'json', 'spots.json'), 'w') do |file|
      results = csv_data.map do |data|
        data = data.to_h
      end
      results.select!{|r| r['place'].present? && r['opening_hours_ja'].present? }
      file.write(JSON.pretty_generate(results))
    end
  end

  desc "イベント情報に変更する"
  task :events do
    csv_data = CSV.read(Rails.root.join('db', 'data', 'csv', '案内用データ - events（イベント情報）.csv'), headers: true)

    File.open(Rails.root.join('db', 'data', 'json', 'events.json'), 'w') do |file|
      results = csv_data.map do |data|
        data = data.to_h
      end
      results.select!{|r| r['place'].present? && r['category'].present? && r['area'].present? && r['highlight_ja'].present? }
      file.write(JSON.pretty_generate(results))
    end
  end

  desc "ロケーション情報に変更する"
  task :locations do
    csv_data = CSV.read(Rails.root.join('db', 'data', 'csv', '案内用データ - locations（構内案内先）.csv'), headers: true)

    File.open(Rails.root.join('db', 'data', 'json', 'locations.json'), 'w') do |file|
      results = csv_data.map do |data|
        data = data.to_h
        hash = {}
        hash['name_ja'] = data['案内先名（name_ja）']
        hash['name_en'] = data['英語名（name_en）']
        hash['alias'] = data['別名（alias）']

        cat_map = {
          'レストラン・お食事' => '1',
          'カフェ・スイーツ' => '2',
          'ショッピング' => '3',
          'ギフト・おみやげ' => '4',
          'コンビニ・スーパー' => '5',
          'その他・サービス' => '6',
          '' => nil
        }
        hash['category_id'] = cat_map[data['カテゴリ（cat）']]

        hash['subcat'] = data['サブカテゴリ（subcat）'].delete("\u0005")
        hash['area'] = data['エリア（area）']
        hash['station'] = data['場所（station）']
        hash['keywords'] = data['キーワード（keywords）'].try(:split, ',')
        hash['postcode'] = data['郵便番号（postcode）']
        hash['addr'] = data['住所（addr）']
        hash['tel'] = data['電話番号（tel）']

        in_map = {
          '内' => true,
          '外' => false,
          '' => nil
        }
        hash['inside'] = in_map[data['構内（inside）']]
        hash['ingate'] = in_map[data['改札内（ingate）']]

        smoke_map = {
          '禁煙' => 0,
          '喫煙' => 1,
          '分煙' => 2,
          '' => nil
        }
        hash['smoking'] = smoke_map[data['喫煙（smoking）']]


        hash['end_point'] = {
          "floor" =>  nil,
          "x" =>  nil,
          "y" =>  nil,
        }
        if end_point = data['座標（end_point）'].try(:split, ',')
          hash['end_point']['floor'] = end_point[0]
          hash['end_point']['x'] = end_point[1]
          hash['end_point']['y'] = end_point[2]
        end


        hash['lnglat'] = {
          'lng' => nil,
          'lat' => nil
        }
        if lnglat = data['緯度経度（lnglat）'].try(:split, ',')
          hash['lnglat']['lng'] = lnglat[0]
          hash['lnglat']['lat'] = lnglat[1]
        end

        hash['biz_hours'] = {
          "sun": {"op": data['日開始時間'], "ed": data['日終了時間']},
          "mon": {"op": data['月開始時間'], "ed": data['月終了時間']},
          "tue": {"op": data['火開始時間'], "ed": data['火終了時間']},
          "wed": {"op": data['水開始時間'], "ed": data['水終了時間']},
          "thu": {"op": data['金開始時間'], "ed": data['金終了時間']},
          "fri": {"op": data['土開始時間'], "ed": data['日終了時間']},
          "sat": {"op": data['日開始時間'], "ed": data['土終了時間']}
        }

        hash['url'] = data['公式サイトURL（url）']

        hash.each{|key, value| hash[key] = nil if value.blank?}
        hash
      end
      results.select!{|r| r['name_ja'].present? && r['end_point'].present? }
      file.write(JSON.pretty_generate(results))
    end
  end

end
