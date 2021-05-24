# frozen_string_literal: true

module Avatax
  class EngineController < ApplicationController
    layout :get_layout

    def get_layout
      layout ||= Avatax.config[:layout]
    end

    def current_tenant_user
      # If the rails application on which that engine is mounted defines such method (Devise), we extract the current user,
      # if not we default to nil, and serve our static mock configuration
      user = current_user if respond_to?(:current_user)
      Avatax.current_tenant_user.call(session, user)
    end
  end
end
