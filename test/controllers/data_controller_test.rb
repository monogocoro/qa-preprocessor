require 'test_helper'

class DataControllerTest < ActionDispatch::IntegrationTest
  test "should get locations" do
    get data_locations_url
    assert_response :success
  end

  test "should get stairs" do
    get data_stairs_url
    assert_response :success
  end

end
