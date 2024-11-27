require "test_helper"

class UrlShortenersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @url_shortener = url_shorteners(:one)
  end

  test "should get index" do
    get url_shorteners_url
    assert_response :success
  end

  test "should get new" do
    get new_url_shortener_url
    assert_response :success
  end

  test "should create url_shortener" do
    assert_difference("UrlShortener.count") do
      post url_shorteners_url, params: { url_shortener: { original: @url_shortener.original, short: @url_shortener.short } }
    end

    assert_redirected_to url_shortener_url(UrlShortener.last)
  end

  test "should show url_shortener" do
    get url_shortener_url(@url_shortener)
    assert_response :success
  end

  test "should get edit" do
    get edit_url_shortener_url(@url_shortener)
    assert_response :success
  end

  test "should update url_shortener" do
    patch url_shortener_url(@url_shortener), params: { url_shortener: { original: @url_shortener.original, short: @url_shortener.short } }
    assert_redirected_to url_shortener_url(@url_shortener)
  end

  test "should destroy url_shortener" do
    assert_difference("UrlShortener.count", -1) do
      delete url_shortener_url(@url_shortener)
    end

    assert_redirected_to url_shorteners_url
  end
end
