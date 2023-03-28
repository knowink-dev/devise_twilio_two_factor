class TwilioTwoFactorAuthClient
  STATUS_PENDING = "pending"
  STATUS_APPROVED = "approved"

  def initialize(resource)
    @resource = resource
    @client = Twilio::REST::Client.new(resource.class.twilio_account_sid, resource.class.twilio_auth_token)
  end

  def send_code
    begin
      response = @client.verify
        .v2
        .services(@resource.class.twilio_verify_service_sid)
        .verifications
        .create(to: @resource.send(@resource.class.otp_destination), channel: @resource.class.communication_type)

      return true if response.status == STATUS_PENDING
      return false
    rescue Twilio::REST::RestError => e
      puts e.message
      return false
    end
  end

  def verify_code(code)
    begin
      response = @client.verify
        .v2
        .services(@resource.class.twilio_verify_service_sid)
        .verification_checks
        .create(to: @resource.send(@resource.class.otp_destination), code: code)
      return true if response.status == STATUS_APPROVED
      return false
    rescue Twilio::REST::RestError => e
      puts e.message
      return false
    end
  end
end

