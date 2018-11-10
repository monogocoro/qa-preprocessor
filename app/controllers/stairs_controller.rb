class StairsController < ApplicationController
  before_action :set_stair, only: [:show, :edit, :update, :destroy]

  # GET /stairs/new
  def new
  end
  # POST /stairs
  # POST /stairs.json
  def create
    data=params[:upload]
    output_path = Rails.root.join('db', 'data', 'csv', '案内用データ - stairs.csv')
    File.open(output_path, 'w+b') do |fp|
      fp.write  data["datafile"].read
    end

    Rails.application.load_tasks
    Rake::Task['to_json:stairs'].execute
    Rake::Task['to_json:stairs'].clear

    rename_from_path = Rails.root.join('db', 'data', 'json', 'stairs.json')
    rename_to_path = Rails.root.join('db', 'data', 'coordinate', 'invert', 'from', 'stairs.json')
    File.rename(rename_from_path,rename_to_path)

    Rake::Task['coordinate:invert'].execute
    Rake::Task['coordinate:invert'].clear

    if params[:commit] == '南が上版をダウンロード'
      redirect_to data_south_stairs_download_path
    elsif params[:commit] == '北が上版をダウンロード'
      redirect_to data_north_stairs_download_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stair
      @stair = Stair.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stair_params
      params.fetch(:stair, {})
    end
end
