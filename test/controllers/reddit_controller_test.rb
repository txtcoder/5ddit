require 'test_helper'

class RedditControllerTest < ActionController::TestCase
  test "should get redirect" do
    get :redirect
    assert_response :success
  end

end
