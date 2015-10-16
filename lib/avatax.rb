require 'avatax/engine'

module Avatax

  mattr_accessor :current_tenant_user
  mattr_accessor :layout

  self.current_tenant_user = lambda { |session, user|
    {:username => 'admin',
     :password => 'password',
     :session_id => nil,
     :api_key => KillBillClient.api_key,
     :api_secret => KillBillClient.api_secret}
  }

  def self.config(&block)
    {
        :layout => layout || 'avatax/layouts/avatax_application',
    }
  end

end
