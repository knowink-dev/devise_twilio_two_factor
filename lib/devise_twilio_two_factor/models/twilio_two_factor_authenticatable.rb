module Devise
  module Models
    module TwilioTwoFactorAuthenticatable
      extend ActiveSupport::Concern

      def verify_factor(code)
        case active_mfa_type
        when :authenticator
          if authenticator_factor_verified?
            return verify_authenticator_challenge(code)
          else
            return verify_authenticator_factor(code)
          end
        when :sms
          verify_sms_code(code)
        end
      end


      # ***** SMS Two Factor Authentication *****

      def send_one_time_password
        twilio_client.send_sms_code
      end

      def verify_one_time_password(code)
        twilio_client.verify_sms_code(code)
      end

      # ***** SMS Helper Methods *****

      def send_sms_otp_after_login?
        active_mfa_type == :sms
      end




      # ***** AUTHENTICATOR Two Factor Authentication *****

      def create_authenticator_factor
        twilio_client.create_authenticator_factor
      end

      def verify_authenticator_factor(code)
        twilio_client.verify_authenticator_factor(code)
      end

      def verify_authenticator_challenge(code)
        twilio_client.verify_authenticator_challenge(code)
      end

      def refresh_authenticator_factor
        self.update(twilio_factor_sid: nil, twilio_factor_secret: nil, twilio_factor_created_at: nil)

        twilio_client.create_authenticator_factor
      end

      # ***** AUTHENTICATOR Helper Methods *****

      def create_authenticator_factor_after_login?
        active_mfa_type == :authenticator && self.twilio_factor_sid.blank?
      end

        # After the first login via authenticator connection is verified and we delete the twilio_factor_secret for security purposes
      def authenticator_factor_verified?
        return unless active_mfa_type == :authenticator

        self.twilio_factor_sid.present? && self.twilio_factor_secret.blank?
      end

        # if factor created for first authenticator login has not been verified in 10 minutes, it is considered expired
      def authenticator_factor_expired?
        return unless active_mfa_type == :authenticator 
        return if authenticator_factor_verified? || self.twilio_factor_created_at.blank?

        expiration_time = self.twilio_factor_created_at + 10.minutes

        Time.now.utc > expiration_time
      end




      # ***** Helper Methods *****


      def login_attempts_exceeded?
        self.failed_attempts.to_i >= Devise.maximum_attempts
      end

      def mfa_timedout?(mfa_login_attempt_expires_at)
        return if mfa_login_attempt_expires_at.blank?

        Time.now.utc > mfa_login_attempt_expires_at
      end

      def need_two_factor_authentication?
        active_mfa_type == :authenticator || active_mfa_type == :sms
      end

      def active_mfa_type
        return :authenticator if self.two_factor_auth_via_authenticator_enabled
        return :sms if self.two_factor_auth_via_sms_enabled
        return :none
      end



      # ***** TWILIO CLIENT *****

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

