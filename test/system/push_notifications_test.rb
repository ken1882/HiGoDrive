require "application_system_test_case"

class PushNotificationsTest < ApplicationSystemTestCase
  setup do
    @push_notification = push_notifications(:one)
  end

  test "visiting the index" do
    visit push_notifications_url
    assert_selector "h1", text: "Push Notifications"
  end

  test "creating a Push notification" do
    visit push_notifications_url
    click_on "New Push Notification"

    click_on "Create Push notification"

    assert_text "Push notification was successfully created"
    click_on "Back"
  end

  test "updating a Push notification" do
    visit push_notifications_url
    click_on "Edit", match: :first

    click_on "Update Push notification"

    assert_text "Push notification was successfully updated"
    click_on "Back"
  end

  test "destroying a Push notification" do
    visit push_notifications_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Push notification was successfully destroyed"
  end
end
