# frozen_string_literal: true

require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  include Avatax::Engine.routes.url_helpers

  test 'can see the main configuration page' do
    get '/avatax'
    assert_response :success
  end

  test 'can see the plugin configuration page' do
    get '/avatax/configuration/plugin'
    assert_response :success
  end
end
