require 'devise/version'

class Devise::TwilioTwoFactorController < DeviseController
  prepend_before_action :authenticate_scope!
  before_action :prepare_and_validate, :handle_two_factor_authentication
  before_action :refresh_authenticator_factor, only: [:update]
  skip_before_action :account_check

  def account_check
  end

  def authenticate_scope!
    self.resource = send("current_#{resource_name}")
  end

  def show
  end

  def update
    render :show and return if params[:code].nil?

    if resource.verify_factor(params[:code])
      after_two_factor_success_for(resource)
    else
      after_two_factor_fail_for(resource)
    end
  end

  def resend_code
    resource.send_otp_code
    redirect_to send("#{resource_name}_twilio_two_factor_path"), notice: I18n.t('devise.twilio_two_factor.code_has_been_sent')
  end

  private

  def after_two_factor_success_for(resource)
    set_remember_two_factor_cookie(resource)

    warden.session(resource_name)[TwoFactorAuthentication::NEED_AUTHENTICATION] = false

    if respond_to?(:bypass_sign_in)
      bypass_sign_in(resource, scope: resource_name)
    else
      sign_in(resource_name, resource, bypass: true)
    end
    set_flash_message :notice, :success
    resource.failed_attempts = 0
    resource.twilio_factor_secret = nil
    resource.save

    users_audit_logger = UsersAuditLogger.new(user: resource, account: resource.account, remote_ip: request.remote_ip, resource: self.class)
    users_audit_logger.mfa_attempt_succeeded

    redirect_to after_two_factor_success_path_for(resource)
  end

  def after_two_factor_fail_for(resource)
    resource.failed_attempts += 1
    resource.save

    users_audit_logger = UsersAuditLogger.new(user: resource, account: resource.account, remote_ip: request.remote_ip, resource: self.class)
    users_audit_logger.mfa_attempt_failed

    set_flash_message :alert, :attempt_failed, now: true

    if resource.login_attempts_exceeded?
      sign_out(resource)
      redirect_to :root
    else
      render :show
    end
  end

  def refresh_authenticator_factor
    if resource.refresh_authenticator_factor
      redirect_to send("#{resource_name}_twilio_two_factor_path"), alert: I18n.t('devise.twilio_two_factor.twilio_authenticator_factor_refreshed')
    else
      redirect_to send("#{resource_name}_twilio_two_factor_path"), alert: I18n.t('devise.twilio_two_factor.twilio_authenticator_factor_refresh_failed')
    end
  end

  def set_remember_two_factor_cookie(resource)
    expires_seconds = resource.class.remember_otp_session_for_seconds

    if expires_seconds && expires_seconds > 0
      cookies.signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME] = {
          value: "#{resource.class}-#{resource.public_send(Devise.second_factor_resource_id)}",
          expires: expires_seconds.seconds.from_now
      }
    end
  end

  def after_two_factor_success_path_for(resource)
    stored_location_for(resource_name) || :root
  end

  def prepare_and_validate
    redirect_to :root and return if resource.nil?

    error_message = I18n.t('devise.twilio_two_factor.mfa_timeout') if resource.mfa_timedout?(warden.session(resource_name)["mfa_login_attempt_expires_at"])
    error_message = I18n.t('devise.twilio_two_factor.attempt_failed') if resource.login_attempts_exceeded?

    return unless error_message

    sign_out(resource)
    redirect_to "/#{resource_name.to_s.pluralize}/sign_in", alert: error_message
  end
end

