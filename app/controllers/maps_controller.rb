require 'zip'
class MapsController < ApplicationController
  before_action :set_map, only: [:show, :edit, :update, :destroy]

  # GET /stairs/new
  def new
  end
  # POST /stairs
  # POST /stairs.json
  def create
    data=params[:upload]
    input_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'maps.zip')
    File.open(input_path, 'w+b') do |fp|
      fp.write  data["datafile"].read
    end

    dest = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from')
    Zip::File.open(input_path) do |zip|
      zip.each do |entry|
        p entry.name
        zip.extract(entry, dest + entry.name) { true }
      end
    end

    Rails.application.load_tasks
    Rake::Task['coordinate:invert'].execute
    Rake::Task['coordinate:invert'].clear

    redirect_to data_maps_download_path
  end

  def closed
    data=params[:upload]
    input_path = Rails.root.join('db', 'data', 'csv', '案内用データ - ブロック.csv')
    File.open(input_path, 'w+b') do |fp|
      fp.write  data["datafile"].read
    end

    Rails.application.load_tasks
    Rake::Task['maps:to_closed'].execute
    Rake::Task['maps:to_closed'].clear

    redirect_to data_maps_closed_download_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_map
      @map = Map.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def map_params
      params.fetch(:map, {})
    end
end
