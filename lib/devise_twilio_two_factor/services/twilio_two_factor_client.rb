class TwilioTwoFactorAuthClient
  STATUS_PENDING = "pending"
  STATUS_APPROVED = "approved"
  STATUS_VERIFIED = "verified"

  def initialize(resource)
    @resource = resource
    @client = Twilio::REST::Client.new(resource.class.twilio_account_sid, resource.class.twilio_auth_token)
  end


  # ***** AUTHENTICATOR Two Factor Authentication *****


  def create_authenticator_factor
    begin
      friendly_name = "#{Devise.host_name.split('.').first} - #{@resource.email}"
      new_factor = @client.verify
        .v2
        .services(@resource.class.twilio_verify_service_sid)
        .entities(@resource.send(@resource.class.entity_id))
        .new_factors
        .create(friendly_name: friendly_name, factor_type: 'totp')

      @resource.update(twilio_factor_sid: new_factor.sid,
                       twilio_factor_secret: new_factor.binding["uri"],
                       twilio_factor_created_at: Time.now.utc
                      )
      return true
    rescue Twilio::REST::RestError => e
      puts e.message
      return false
    end
  end

  def verify_authenticator_factor(code)
    begin
      response = @client.verify.v2
        .services(@resource.class.twilio_verify_service_sid)
        .entities(@resource.send(@resource.class.entity_id))
        .factors(@resource.twilio_factor_sid)
        .update(auth_payload: code)


      return true if response.status == STATUS_VERIFIED
      return false
    rescue Twilio::REST::RestError => e
      puts e.message
      return false
    end
  end

  def verify_authenticator_factor(code)
    begin
      response = @client.verify.v2
        .services(@resource.class.twilio_verify_service_sid)
        .entities(@resource.send(@resource.class.entity_id))
        .challenges
        .create(
          auth_payload: code,
          factor_sid: @resource.twilio_factor_sid
        )

      return true if response.status == STATUS_APPROVED
      return false
    rescue Twilio::REST::RestError => e
      puts e.message
      return false
    end
  end


  # ***** SMS Two Factor Authentication *****


  def send_sms_code
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

  def verify_sms_code(code)
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

