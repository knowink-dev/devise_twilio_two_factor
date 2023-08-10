module Devise
  module Models
    module TwilioTwoFactorAuthenticatable
      extend ActiveSupport::Concern

      def send_otp_code
        twilio_client.send_code
      end

      def create_new_totp_factor
        twilio_client.create_new_totp_factor
      end

      def verify_otp_code(code)
        twilio_client.verify_otp_code(code)
      end

      def verify_totp_factor(code)
        twilio_client.verify_totp_factor(code)
      end

      def verify_totp_challenge(code)
        twilio_client.verify_totp_challenge(code)
      end

      def login_attempts_exceeded?
        self.failed_attempts.to_i >= Devise.maximum_attempts
      end

      def need_two_factor_authentication?
        self.otp_required_for_login || self.totp_enabled
      end

      def send_new_otp_after_login?
        return false if self.totp_enabled

        self.otp_required_for_login
      end

      def create_new_totp_factor_after_login?
        self.totp_enabled && self.twilio_factor_sid.blank?
      end

      def factor_verified?(code)
        if self.totp_enabled
          self.twilio_factor_secret.present? ? verify_totp_factor(code) : verify_totp_challenge(code)
        else
          verify_otp_code(code)
        end
      end

      private def twilio_client
        @twilio_client ||= TwilioTwoFactorAuthClient.new(self)
      end

      protected
      module ClassMethods
        Devise::Models.config(self, 
                              :otp_code_length, 
                              :otp_destination,
                              :entity_id,
                              :communication_type, 
                              :remember_otp_session_for_seconds,
                              :second_factor_resource_id,
                              :twilio_verify_service_sid,
                              :twilio_auth_token, 
                              :twilio_account_sid)
      end
    end
  end
end
