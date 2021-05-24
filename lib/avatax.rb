# frozen_string_literal: true

require 'avatax/engine'

module Avatax
  mattr_accessor :current_tenant_user
  mattr_accessor :layout

  self.current_tenant_user = lambda { |_session, _user|
    { username: 'admin',
      password: 'password',
      session_id: nil,
      api_key: KillBillClient.api_key,
      api_secret: KillBillClient.api_secret }
  }

  def self.config
    {
      layout: layout || 'avatax/layouts/avatax_application'
    }
  end
end
