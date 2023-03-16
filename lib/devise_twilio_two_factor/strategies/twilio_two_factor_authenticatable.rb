module Devise
  module Strategies
    class TwilioTwoFactorAuthenticatable < Devise::Strategies::DatabaseAuthenticatable

      def authenticate!
        resource = mapping.to.find_for_database_authentication(authentication_hash)
        # We authenticate in two cases:
        # 1. The password and the OTP are correct
        # 2. The password is correct, and OTP is not required for login
        # We check the OTP, then defer to DatabaseAuthenticatable
        if validate(resource) { validate_otp(resource) }
          super
        end

        fail(Devise.paranoid ? :invalid : :not_found_in_database) unless resource

        @halted = false if @result == :failure
      end

      def validate_otp(resource)
        return true unless resource.otp_required_for_login
        return if params[scope]['otp_attempt'].nil?
        resource.validate_twilio_otp!(params[scope]['otp_attempt'])
      end
    end
  end
end

Warden::Strategies.add(:twilio_two_factor_authenticatable, Devise::Strategies::TwilioTwoFactorAuthenticatable)

