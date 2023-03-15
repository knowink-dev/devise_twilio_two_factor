require 'spec_helper'

class TwilioTwoFactorAuthenticatableDouble
  extend ::ActiveModel::Callbacks
  include ::ActiveModel::Validations::Callbacks
  extend  ::Devise::Models

  define_model_callbacks :update

  devise :twilio_two_factor_authenticatable

  def save(validate)
    # noop for testing
    true
  end
end

RSpec.describe ::Devise::Models::TwilioTwoFactorAuthenticatable do
  context 'When included in a class' do
    subject { TwilioTwoFactorAuthenticatableDouble.new }

    it 'leverages twilio verify api to send user otp code' do
      response = subject.send_twilio_2fa_otp!

      expect(response).to eq("sent code to user!")
    end

    it 'validates the user input otp code with twilio api' do
      code = '1234321'
      response = subject.validate_twilio_2fa_otp!(code)

      expect(response).to eq("user provided code #{code} is valid")
    end
  end
end


