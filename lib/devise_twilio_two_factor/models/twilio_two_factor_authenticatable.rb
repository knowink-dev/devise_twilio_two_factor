module Devise
  module Models
    module TwilioTwoFactorAuthenticatable
      extend ActiveSupport::Concern
      include Devise::Models::DatabaseAuthenticatable

      included do
        attr_accessor :otp_attempt
      end

      def send_twilio_2fa_otp!
        # implement twilio call to generate and send otp to user
        return "sent code to user!"
      end

      def validate_twilio_2fa_otp!(code)
        # implement twilio call for verification
        return "user provided code #{code} is valid"
      end

    protected
      module ClassMethods
        Devise::Models.config(self)
      end
    end
  end
end
