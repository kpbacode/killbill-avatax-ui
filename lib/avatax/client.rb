module Killbill
  module Avatax

    class AvataxClient < KillBillClient::Model::Resource

      KILLBILL_AVATAX_PREFIX = '/plugins/killbill-avatax'

      class << self

        def set_exemption(account_id, customer_usage_type, user, reason, comment, options = {})
          exemptionCustomFieldName = 'customerUsageType'

          account = KillBillClient::Model::Account.find_by_id(account_id, false, false, options)

          # Remove existing exemption(s) first
          account.custom_fields('NONE', options).each do |custom_field|
            account.remove_custom_field(custom_field.custom_field_id, user, reason, comment, options) if custom_field.name == exemptionCustomFieldName
          end

          unless customer_usage_type.nil?
            # Set the exemption
            custom_field = KillBillClient::Model::CustomField.new
            custom_field.name = exemptionCustomFieldName
            custom_field.value = customer_usage_type
            account.add_custom_field(custom_field, user, reason, comment, options)
          end
        end

        def remove_exemption(account_id, user, reason, comment, options = {})
          set_exemption(account_id, nil, user, reason, comment, options)
        end

        def get_tax_codes(options = {})
          path = "#{KILLBILL_AVATAX_PREFIX}/taxCodes"
          response = KillBillClient::API.get path, {}, options
          JSON.parse(response.body).map(&:symbolize_keys)
        end

        def get_tax_code(product_name, options = {})
          path = "#{KILLBILL_AVATAX_PREFIX}/taxCodes/#{product_name}"
          response = KillBillClient::API.get path, {}, options
          JSON.parse(response.body).symbolize_keys
        end

        def set_tax_code(product_name, tax_code, user, reason, comment, options = {})
          body = {:productName => product_name, :taxCode => tax_code}.to_json

          path = "#{KILLBILL_AVATAX_PREFIX}/taxCodes"
          response = KillBillClient::API.post path, body, {}, options
          response.body
        end

        def remove_tax_code(product_name, user, reason, comment, options= {})
          path = "#{KILLBILL_AVATAX_PREFIX}/taxCodes/#{product_name}"
          KillBillClient::API.delete path, nil, {}, options
        end

      end

    end

  end
end
