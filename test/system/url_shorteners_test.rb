require "application_system_test_case"

class UrlShortenersTest < ApplicationSystemTestCase
  setup do
    @url_shortener = url_shorteners(:one)
  end

  test "visiting the index" do
    visit url_shorteners_url
    assert_selector "h1", text: "Url shorteners"
  end

  test "should create url shortener" do
    visit url_shorteners_url
    click_on "New url shortener"

    fill_in "Original", with: @url_shortener.original
    fill_in "Short", with: @url_shortener.short
    click_on "Create Url shortener"

    assert_text "Url shortener was successfully created"
    click_on "Back"
  end

  test "should update Url shortener" do
    visit url_shortener_url(@url_shortener)
    click_on "Edit this url shortener", match: :first

    fill_in "Original", with: @url_shortener.original
    fill_in "Short", with: @url_shortener.short
    click_on "Update Url shortener"

    assert_text "Url shortener was successfully updated"
    click_on "Back"
  end

  test "should destroy Url shortener" do
    visit url_shortener_url(@url_shortener)
    click_on "Destroy this url shortener", match: :first

    assert_text "Url shortener was successfully destroyed"
  end
end
