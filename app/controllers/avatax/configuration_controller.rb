require 'avatax/client'

module Avatax
  class ConfigurationController < EngineController

    def index
      @tax_codes = ::Killbill::Avatax::AvataxClient.get_tax_codes(options_for_klient)
      @exemptions = exempt_accounts
    end

    #
    # Tax Codes
    #

    def set_tax_code
      @products = KillBillClient::Model::Catalog.simple_catalog(options_for_klient).last.products.map(&:name)
    end

    def do_set_tax_code
      ::Killbill::Avatax::AvataxClient.set_tax_code(params.require(:product_name),
                                                    params.require(:tax_code),
                                                    options_for_klient[:username],
                                                    params[:reason],
                                                    params[:comment],
                                                    options_for_klient)

      flash[:notice] = 'Tax code successfully saved'
      redirect_to :action => :index
    end

    def remove_tax_code
      ::Killbill::Avatax::AvataxClient.remove_tax_code(params.require(:product_name),
                                                       options_for_klient[:username],
                                                       params[:reason],
                                                       params[:comment],
                                                       options_for_klient)

      flash[:notice] = 'Tax code successfully removed'
      redirect_to :action => :index
    end

    #
    # Exemptions
    #

    def set_exemption
    end

    def do_set_exemption
      ::Killbill::Avatax::AvataxClient.set_exemption(params.require(:account_id),
                                                     params.require(:customer_usage_type),
                                                     options_for_klient[:username],
                                                     params[:reason],
                                                     params[:comment],
                                                     options_for_klient)

      flash[:notice] = 'Exemption successfully saved'
      redirect_to :action => :index
    end

    def remove_exemption
      ::Killbill::Avatax::AvataxClient.remove_exemption(params.require(:account_id),
                                                        options_for_klient[:username],
                                                        params[:reason],
                                                        params[:comment],
                                                        options_for_klient)

      flash[:notice] = 'Exemption successfully removed'
      redirect_to :action => :index
    end

    #
    # Settings
    #

    def plugin_configuration
      @configuration = {}

      config = KillBillClient::Model::Tenant.get_tenant_plugin_config('killbill-avatax', options_for_klient)
      return if config.values.empty?

      config.values.first.split.each do |property|
        k, v = property.split('=')
        case k
          when 'org.killbill.billing.plugin.avatax.url'
            @configuration[:test] = avatax_url(true) == v
          when 'org.killbill.billing.plugin.avatax.accountNumber'
            @configuration[:account_number] = v
          when 'org.killbill.billing.plugin.avatax.licenseKey'
            @configuration[:license_key] = v
          when 'org.killbill.billing.plugin.avatax.companyCode'
            @configuration[:company_code] = v
          when 'org.killbill.billing.plugin.avatax.commitDocuments'
            @configuration[:commit_documents] = v == 'true'
        end
      end
    end

    def update_plugin_configuration
      plugin_config = "org.killbill.billing.plugin.avatax.url=#{avatax_url(params[:test] == '1')}
org.killbill.billing.plugin.avatax.accountNumber=#{params.require(:account_number)}
org.killbill.billing.plugin.avatax.licenseKey=#{params.require(:license_key)}
org.killbill.billing.plugin.avatax.companyCode=#{params[:company_code]}
org.killbill.billing.plugin.avatax.commitDocuments=#{params[:commit_documents] == '1'}"

      KillBillClient::Model::Tenant.upload_tenant_plugin_config('killbill-avatax',
                                                                plugin_config,
                                                                options_for_klient[:username],
                                                                params[:reason],
                                                                params[:comment],
                                                                options_for_klient)

      flash[:notice] = 'Configuration successfully saved'
      redirect_to :action => :index
    end

    private

    def avatax_url(test)
      "https://#{test ? 'development' : 'avatax'}.avalara.net"
    end

    def exempt_accounts(offset = 0, limit = 100)
      custom_field_value = 'customerUsageType'

      KillBillClient::Model::CustomField.find_in_batches_by_search_key(custom_field_value, offset, limit, options_for_klient)
          .select { |cf| cf.name == custom_field_value && cf.object_type == 'ACCOUNT' }
          .map { |cf| {:account_id => cf.object_id, :customer_usage_type => cf.value} }
    end

    def options_for_klient
      user = current_tenant_user
      {
          :username => user[:username],
          :password => user[:password],
          :session_id => user[:session_id],
          :api_key => user[:api_key],
          :api_secret => user[:api_secret]
      }
    end
  end
end
