namespace :coordinate do
  desc "座標を反転する"
  task :invert do

    def invert(item)
      100 - item.to_i
    end

    # Stairを反転
    from_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'stairs.json')
    to_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'stairs.json')
    stairs = open(from_path) do |io|
      JSON.load(io)
    end
    stairs.map! do |stair|
      stair = stair.to_h
      stair['end_points'].map do |end_point|
        end_point['x'] = invert(end_point['x'])
        end_point['y'] = invert(end_point['y'])
        end_point
      end
      stair
    end
    File.open(to_path, 'w') do |file|
      file.write(JSON.pretty_generate(stairs))
    end

    # Locationを反転
    from_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'locations.json')
    to_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'locations.json')

    locations = open(from_path) do |io|
      JSON.load(io)
    end
    locations.map! do |location|
      location = location.to_h
      location['end_point']['x'] = invert(location['end_point']['x'])
      location['end_point']['y'] = invert(location['end_point']['y'])
      location
    end
    File.open(to_path, 'w') do |file|
      file.write(JSON.pretty_generate(locations))
    end

    # Landmarkを反転
    from_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'landmarks.json')
    to_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'landmarks.json')

    landmarks = open(from_path) do |io|
      JSON.load(io)
    end
    landmarks.map! do |landmark|
      landmark = landmark.to_h
      landmark['end_point']['x'] = invert(landmark['end_point']['x'])
      landmark['end_point']['y'] = invert(landmark['end_point']['y'])
      landmark
    end
    File.open(to_path, 'w') do |file|
      file.write(JSON.pretty_generate(landmarks))
    end

    # GridDataを反転
    from_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'maps')
    to_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'maps.json')
    sort_table = %w(B3 B2 P B1 1 2 M3 3 4 M5 5 6 7 M8 8 9 10 11 R 15)

    maps = []
    grid_size = 99
    Dir.foreach(from_path) do |item|
      next if item == '.' or item == '..'

      grid = open(from_path.join(item)) do |io|
        str = io.read
        str.sub!(/],\n$/, "]")
        JSON.parse('[' + str + ']')
      end

      # 反転
      grid = grid.map{ |row| row.reverse }.reverse

      name = item.sub('grid_Data', '').sub('.txt', '')
      floor = name.sub('F', '').upcase

      maps << {
        "number" => sort_table.index(floor),
        "name" => name,
        "floor" => floor,
        "width" => grid_size + 1,
        "height" => grid_size + 1,
        "grid" => grid
      }
    end

    #ソート
    maps.sort! {|a, b| a["number"] <=> b["number"]}
    maps.map!{|m| m.delete("number"); m}

    # 整形, 書き出し
    File.open(to_path, 'w') do |file|
      json = JSON.pretty_generate(maps)
      json.gsub!(/\s+(1|0),\s+/, '\1,')
      json.gsub!(/,(1|0)\s+\]/, ',\1]')
      file.write(json)
    end
  end
end
