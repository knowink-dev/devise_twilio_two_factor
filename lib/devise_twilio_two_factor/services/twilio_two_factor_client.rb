class TwilioTwoFactorAuthClient

  attr_reader :client, :service
  
  def initialize(twilio_account_sid, twilio_auth_token, app_name)
    @client = Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token) || nil
    @service = @client.verify.v2.services.create(friendly_name: app_name) || nil
  end

  def send_otp_code(destination, communication_type = 'sms')
    begin
       @client.verify
        .v2
        .services(@service.sid)
        .verifications
        .create(to: destination, channel: communication_type)
      return true
    rescue => e
      puts e
      return false
    end
  end
  
  def verify_otp_code(destination, code)
    begin
      @client.verify
        .v2
        .services(@service.sid)
        .verification_checks
        .create(to: destination, code: code)
      return true
    rescue => e
      puts e
      return false
    end
  end
end

