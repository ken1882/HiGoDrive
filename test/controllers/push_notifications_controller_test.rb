require 'test_helper'

class PushNotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @push_notification = push_notifications(:one)
  end

  test "should get index" do
    get push_notifications_url
    assert_response :success
  end

  test "should get new" do
    get new_push_notification_url
    assert_response :success
  end

  test "should create push_notification" do
    assert_difference('PushNotification.count') do
      post push_notifications_url, params: { push_notification: {  } }
    end

    assert_redirected_to push_notification_url(PushNotification.last)
  end

  test "should show push_notification" do
    get push_notification_url(@push_notification)
    assert_response :success
  end

  test "should get edit" do
    get edit_push_notification_url(@push_notification)
    assert_response :success
  end

  test "should update push_notification" do
    patch push_notification_url(@push_notification), params: { push_notification: {  } }
    assert_redirected_to push_notification_url(@push_notification)
  end

  test "should destroy push_notification" do
    assert_difference('PushNotification.count', -1) do
      delete push_notification_url(@push_notification)
    end

    assert_redirected_to push_notifications_url
  end
end
