class MapController < ApplicationController
  def show
    results = params[:items].map{|item| item.split(',')}
    @has_external = results.select{|result| result[0] == '2'}.present?
    # @has_b1f = true
    # @has_1f = true
    # @has_2f = true

    @has_b1f = results.select{|result| result[0] == '1' && result[1] == '0'}.present?
    @has_1f = results.select{|result| result[0] == '1' && result[1] == '1'}.present?
    @has_2f = results.select{|result| result[0] == '1' && result[1] == '2'}.present?
    @numbers = results.map{|result| result[0] + ',' + result[1] + ',' + result[2] + ',' + result[3]}
  end

  def test
  end
  def test2f
  end

  def landform
  end
  def landform2f
  end

  def xy
  end
end
