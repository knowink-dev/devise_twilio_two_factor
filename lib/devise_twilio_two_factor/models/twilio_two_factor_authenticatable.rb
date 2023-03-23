module Devise
  module Models
    module TwilioTwoFactorAuthenticatable
      extend ActiveSupport::Concern
      include Devise::Models::DatabaseAuthenticatable

      included do
        attr_accessor :otp_attempt
      end

      def send_otp_code!
        @twilio_client = TwilioTwoFactorAuthClient.new(Devise.twilio_account_sid, Devise.twilio_auth_token, Devise.otp_sender_name)
        @twilio_client.send_otp_code(self.send(self.class.otp_destination), self.class.communication_type) 
      end

      def verify_otp_code!

      end

    protected
      module ClassMethods
        Devise::Models.config(self, 
                              :otp_code_length, 
                              :otp_destination,
                              :otp_sender_name,
                              :communication_type, 
                              :twilio_auth_token, 
                              :twilio_account_sid)
      end
    end
  end
end
