Avatax::Engine.routes.draw do

  root to: 'configuration#index'

  resources :configuration, :only => [:index]

  scope '/configuration' do
    match '/tax_code' => 'configuration#set_tax_code', :via => :get, :as => 'set_tax_code_configuration'
    match '/tax_code' => 'configuration#do_set_tax_code', :via => :post, :as => 'do_set_tax_code_configuration'

    match '/exemption' => 'configuration#set_exemption', :via => :get, :as => 'set_exemption_configuration'
    match '/exemption' => 'configuration#do_set_exemption', :via => :post, :as => 'do_set_exemption_configuration'

    match '/plugin' => 'configuration#plugin_configuration', :via => :get, :as => 'plugin_configuration'
    match '/plugin' => 'configuration#update_plugin_configuration', :via => :post, :as => 'update_plugin_configuration'
  end

end
