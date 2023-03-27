module Devise
  module Models
    module TwilioTwoFactorAuthenticatable
      extend ActiveSupport::Concern

      def send_otp_code
        twilio_client.send_code
      end

      def verify_otp_code(code)
        twilio_client.verify_code(code)
      end

      def login_attempts_exceeded?
        self.failed_attempts.to_i >= Devise.maximum_attempts
      end

      def need_two_factor_authentication?(request)
        self.otp_required_for_login
      end

      def send_new_otp_after_login?
        self.otp_required_for_login
      end

      private def twilio_client
        @twilio_client ||= TwilioTwoFactorAuthClient.new(self)
      end

      protected
      module ClassMethods
        Devise::Models.config(self, 
                              :otp_code_length, 
                              :otp_destination,
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
