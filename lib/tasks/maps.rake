namespace :maps do
  task :to_closed do
    # GridDataを反転
    from_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'maps.json')
    block_path = Rails.root.join('db', 'data', 'csv', '案内用データ - ブロック.csv')
    to_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'maps_closed.json')
    sort_table = %w(B3 B2 P B1 1 2 M3 3 4 M5 5 6 7 M8 8 9 10 11 R 15)

    csv_data = CSV.read(block_path, headers: true)

    maps = open(from_path) do |io|
      JSON.load(io)
    end

    maps.map do |map|
      csv_data.each do |block|
        point = block['point'].split(',')
        if map['floor'] == point[0].upcase
          # debugger
          x = 99 - point[1].to_i
          y = 99 - point[2].to_i
          puts point[0].upcase + ',' + x.to_s + ',' + y.to_s + ',' + map['grid'][y][x].to_s
          map['grid'][y][x] = 1
        end
      end
      # map['grid'] = map['grid'].map{ |row| row.reverse }.reverse
      map
    end

    File.open(to_path, 'w') do |file|
      json = JSON.pretty_generate(maps)
      json.gsub!(/\s+(1|0),\s+/, '\1,')
      json.gsub!(/,(1|0)\s+\]/, ',\1]')
      file.write(json)
    end
  end

end
