require 'test_helper'

class StairsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stair = stairs(:one)
  end

  test "should get index" do
    get stairs_url
    assert_response :success
  end

  test "should get new" do
    get new_stair_url
    assert_response :success
  end

  test "should create stair" do
    assert_difference('Stair.count') do
      post stairs_url, params: { stair: {  } }
    end

    assert_redirected_to stair_url(Stair.last)
  end

  test "should show stair" do
    get stair_url(@stair)
    assert_response :success
  end

  test "should get edit" do
    get edit_stair_url(@stair)
    assert_response :success
  end

  test "should update stair" do
    patch stair_url(@stair), params: { stair: {  } }
    assert_redirected_to stair_url(@stair)
  end

  test "should destroy stair" do
    assert_difference('Stair.count', -1) do
      delete stair_url(@stair)
    end

    assert_redirected_to stairs_url
  end
end
