class TwilioTwoFactorAuthClient
  
  def initialize(account)
    account_sid = ENV['TWILIO_ACCOUNT_SID'] || Settings.messages.account_id
    auth_token = ENV['TWILIO_AUTH_TOKEN'] || Settings.messages.token
    @client = Twilio::REST::Client.new(account_sid, auth_token) || nil
    @service = @client.verify.v2.services.create(friendly_name: 'Two Factor Authentication') || nil
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

