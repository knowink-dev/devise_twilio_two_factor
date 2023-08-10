require 'spec_helper'

class TwilioTwoFactorAuthenticatableDouble
  extend ::ActiveModel::Callbacks
  include ::ActiveModel::Validations::Callbacks
  extend  ::Devise::Models

  devise :twilio_two_factor_authenticatable, otp_destination: "phone", communication_type: "sms", entity_id: "uid"
end

RSpec.describe ::Devise::Models::TwilioTwoFactorAuthenticatable do
  context 'When included in a class' do
    subject { TwilioTwoFactorAuthenticatableDouble.new }

    it 'creates class variables with the options passed' do
      expect(subject.class.otp_destination).to eq("phone")
      expect(subject.class.communication_type).to eq("sms")
    end

    it 'has access to class variables defined in Devise' do
      expect(subject.class.otp_code_length).to eq(6)
      expect(subject.class.twilio_account_sid).to eq("ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
      expect(subject.class.twilio_auth_token).to eq("token")
      expect(subject.class.twilio_verify_service_sid).to eq("VAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
      expect(subject.class.second_factor_resource_id).to eq("id")
      expect(subject.class.remember_otp_session_for_seconds).to eq(30.minutes)
    end

    describe ".send_otp_code" do
      let(:twilio_client) { instance_double(TwilioTwoFactorAuthClient) }
      before do
        allow_any_instance_of(TwilioTwoFactorAuthClient).to receive(:send_code) { true }
        allow(TwilioTwoFactorAuthClient).to receive(:new).and_return(twilio_client)
      end

      it 'instantiates twilio client and tells client to send code' do
        expect(TwilioTwoFactorAuthClient).to receive(:new).with(subject)
        expect(twilio_client).to receive(:send_code)

        subject.send_otp_code
      end
    end

    describe '.verify_otp_code' do
      let(:twilio_client) { instance_double(TwilioTwoFactorAuthClient) }
      let(:code) { "123456" }
      before do
        allow_any_instance_of(TwilioTwoFactorAuthClient).to receive(:verify_otp_code).with(code) { true }
        allow(TwilioTwoFactorAuthClient).to receive(:new).and_return(twilio_client)
      end

      it 'instantiates twilio client and calls verify_otp_code' do
        expect(TwilioTwoFactorAuthClient).to receive(:new).with(subject)
        expect(twilio_client).to receive(:verify_otp_code).with(code)

        subject.verify_otp_code(code)
      end
    end

    describe '.login_attempts_exceeded?' do
      it 'should return false unless locked_at is defined' do
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:failed_attempts) { 0 }
        expect(subject.login_attempts_exceeded?).to eq(false)
      end

      it 'should return true if login_attempts exceeds max login attempts' do
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:failed_attempts) { 100 }

        expect(subject.login_attempts_exceeded?).to eq(true)
      end
    end

    describe '.send_new_otp_after_login?' do
      it 'should return false if otp_required_for_login is false' do
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:otp_required_for_login) { false }
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:totp_enabled) { false }


        expect(subject.send_new_otp_after_login?).to eq(false)
      end

      it 'should return true if otp_required_for_login is true' do
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:otp_required_for_login) { true }
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:totp_enabled) { false }


        expect(subject.send_new_otp_after_login?).to eq(true)
      end

      it 'should return true if totp_enabled is true' do
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:otp_required_for_login) { false }
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:totp_enabled) { true }


        expect(subject.send_new_otp_after_login?).to eq(true)
      end

      it 'should return true if totp_enabled is true and otp_required_for_login is true' do
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:otp_required_for_login) { true }
        allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:totp_enabled) { true }


        expect(subject.send_new_otp_after_login?).to eq(true)
      end
    end
  end
end


