class TwilioTwoFactorAuthClient
  STATUS_PENDING = "pending"
  STATUS_APPROVED = "approved"
  STATUS_CANCELLED = "cancelled"

  def initialize(resource) @resource = resource
    @client = Twilio::REST::Client.new(resource.class.twilio_account_sid, resource.class.twilio_auth_token)
    @service =  @client.verify.v2.services(resource.class.twilio_verify_service_sid).fetch
  end

  def send_code
    begin
      response = @client.verify
        .v2
        .services(@service.sid)
        .verifications
        .create(to: @resource.send(@resource.class.otp_destination), channel: @resource.class.communication_type)
      return true if response.status == STATUS_PENDING
    rescue => e
      puts e
      return false
    end
  end

  def verify_code(code)
    begin
      response = @client.verify
        .v2
        .services(@service.sid)
        .verification_checks
        .create(to: @resource.send(@resource.class.otp_destination), code: code)
      return true if response.status == STATUS_APPROVED
    rescue => e
      puts e
      return false
    end
  end
end

