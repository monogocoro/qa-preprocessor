class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  # GET /locations/new
  def new
  end
  # POST /locations
  # POST /locations.json
  def create
    data=params[:upload]
    output_path = Rails.root.join('db', 'data', 'csv', '案内用データ - locations（構内案内先）.csv')
    File.open(output_path, 'w+b') do |fp|
      fp.write  data["datafile"].read
    end

    Rails.application.load_tasks
    Rake::Task['to_json:locations'].execute
    Rake::Task['to_json:locations'].clear

    rename_from_path = Rails.root.join('db', 'data', 'json', 'locations.json')
    rename_to_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'locations.json')
    File.rename(rename_from_path,rename_to_path)

    Rake::Task['coordinate:invert'].execute
    Rake::Task['coordinate:invert'].clear

    if params[:commit] == '南が上版をダウンロード'
      redirect_to data_south_locations_download_path
    elsif params[:commit] == '北が上版をダウンロード'
      redirect_to data_north_locations_download_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.fetch(:location, {})
    end
end
