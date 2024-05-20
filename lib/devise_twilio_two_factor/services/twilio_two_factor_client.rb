class TwilioTwoFactorAuthClient
  STATUS_PENDING = "pending".freeze
  STATUS_APPROVED = "approved".freeze
  STATUS_VERIFIED = "verified".freeze
  STATUS_UNVERIFIED = "unverified".freeze

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

      new_factor.status == STATUS_UNVERIFIED
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


      response.status == STATUS_VERIFIED
    rescue Twilio::REST::RestError => e
      puts e.message
      return false
    end
  end

  def verify_authenticator_challenge(code)
    begin
      response = @client.verify.v2
        .services(@resource.class.twilio_verify_service_sid)
        .entities(@resource.send(@resource.class.entity_id))
        .challenges
        .create(
          auth_payload: code,
          factor_sid: @resource.twilio_factor_sid
        )

      response.status == STATUS_APPROVED
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

      response.status == STATUS_PENDING
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

      response.status == STATUS_APPROVED
    rescue Twilio::REST::RestError => e
      puts e.message
      return false
    end
  end
end

