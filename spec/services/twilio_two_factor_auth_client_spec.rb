require 'spec_helper'

class TwilioTwoFactorAuthenticatableDouble
  extend ::ActiveModel::Callbacks
  include ::ActiveModel::Validations::Callbacks
  extend  ::Devise::Models

  devise :twilio_two_factor_authenticatable, otp_destination: "phone", communication_type: "sms"
end

RSpec.describe TwilioTwoFactorAuthClient, type: :service do
  let(:twilio_client) { instance_double(Twilio::REST::Client) }
  let(:mock_number) { "+16309437616" }
  let(:mock_twilio_response) { instance_double("twilio_response") }
  let(:mock_code) { "123456" }

  before do
    allow_any_instance_of(TwilioTwoFactorAuthenticatableDouble).to receive(:phone).and_return(mock_number)
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
  end

  describe 'new' do
    it 'should instantiate twilio client' do
      expect(Twilio::REST::Client).to receive(:new).and_return(twilio_client)

      TwilioTwoFactorAuthClient.new(TwilioTwoFactorAuthenticatableDouble.new)
    end
  end

  describe '#send_code' do
    describe 'code was send successfully' do
      it 'should have status pending and return true' do
        allow(mock_twilio_response).to receive(:status).and_return("pending")
        allow(twilio_client).to receive_message_chain(:verify, :v2, :services, :verifications, :create).and_return(mock_twilio_response) 
        expect(twilio_client).to receive_message_chain(:verify, :v2, :services, :verifications, :create) 

        response = TwilioTwoFactorAuthClient.new(TwilioTwoFactorAuthenticatableDouble.new).send_code
        expect(response).to eq(true)
      end
    end

    describe 'failed to send code' do
      it 'it should have status cancelled and return false' do
        allow(mock_twilio_response).to receive(:status).and_return("cancelled")
        allow(twilio_client).to receive_message_chain(:verify, :v2, :services, :verifications, :create).and_return(mock_twilio_response) 
        expect(twilio_client).to receive_message_chain(:verify, :v2, :services, :verifications, :create) 

        response = TwilioTwoFactorAuthClient.new(TwilioTwoFactorAuthenticatableDouble.new).send_code
        expect(response).to eq(false)
      end
    end
  end

  describe '#verify_otp_code' do
    describe 'code was verified' do
      it 'should return a status of approved and true' do
        allow(mock_twilio_response).to receive(:status).and_return("approved")
        allow(twilio_client).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create).and_return(mock_twilio_response) 
        expect(twilio_client).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create) 

        response = TwilioTwoFactorAuthClient.new(TwilioTwoFactorAuthenticatableDouble.new).verify_otp_code(mock_code)
        expect(response).to eq(true)
      end
    end

    describe 'code could not be verified' do
      it 'should return a status of pending and false' do
        allow(mock_twilio_response).to receive(:status).and_return("pending")
        allow(twilio_client).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create).and_return(mock_twilio_response) 
        expect(twilio_client).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create) 

        response = TwilioTwoFactorAuthClient.new(TwilioTwoFactorAuthenticatableDouble.new).verify_otp_code(mock_code)
        expect(response).to eq(false)
      end
    end
  end

  describe '#create_authenticator_factor' do
    describe 'factor was created' do
      it 'should return true' do
        allow(mock_twilio_response).to receive(:status).and_return("pending")
        allow(twilio_client).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create).and_return(mock_twilio_response) 
        expect(twilio_client).to receive_message_chain(:verify, :v2, :services, :verification_checks, :create) 

        response = TwilioTwoFactorAuthClient.new(TwilioTwoFactorAuthenticatableDouble.new).verify_otp_code(mock_code)
        expect(response).to eq(false)
      end
    end


  end
end
