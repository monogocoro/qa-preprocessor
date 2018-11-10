class DataController < ApplicationController
  def south_locations_download
    return_file_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'locations.json')
    stat = File::stat(return_file_path)
    send_file(return_file_path, :filename => 'locations.json', :length => stat.size)
  end

  def north_locations_download
    return_file_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'locations.json')
    stat = File::stat(return_file_path)
    send_file(return_file_path, :filename => 'locations_north.json', :length => stat.size)
  end

  def south_stairs_download
    return_file_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'stairs.json')
    stat = File::stat(return_file_path)
    send_file(return_file_path, :filename => 'stairs.json', :length => stat.size)
  end

  def north_stairs_download
    return_file_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'stairs.json')
    stat = File::stat(return_file_path)
    send_file(return_file_path, :filename => 'stairs_north.json', :length => stat.size)
  end

  def maps_download
    return_file_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'maps.json')
    stat = File::stat(return_file_path)
    send_file(return_file_path, :filename => 'maps.json', :length => stat.size)
  end
  def maps_closed_download
    return_file_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'to', 'maps_closed.json')
    stat = File::stat(return_file_path)
    send_file(return_file_path, :filename => 'maps.json', :length => stat.size)
  end
end
