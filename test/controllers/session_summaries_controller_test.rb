require 'test_helper'

class SessionSummariesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get session_summaries_show_url
    assert_response :success
  end

end
