Warden::Manager.after_set_user :only => [:set_user, :authentication] do |user, auth, options|
  if auth.env["action_dispatch.cookies"]
    expected_cookie_value = "#{user.class}-#{user.public_send(Devise.second_factor_resource_id)}"
      actual_cookie_value = auth.env["action_dispatch.cookies"].signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME]
    bypass_by_cookie = actual_cookie_value == expected_cookie_value
  end

  if user.respond_to?(:need_two_factor_authentication?) && !bypass_by_cookie
    if auth.session(options[:scope])[TwoFactorAuthentication::NEED_AUTHENTICATION] = user.need_two_factor_authentication?
      auth.session(options[:scope])["mfa_login_attempt_expires_at"] = Devise.time_to_authenticate.seconds.from_now.utc
      user.send_sms_code if user.send_sms_otp_after_login?
      user.create_authenticator_factor if user.create_authenticator_factor_after_login?
    end
  end
end

Warden::Manager.before_logout do |user, auth, _options|
  auth.cookies.delete TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME if Devise.delete_cookie_on_logout
end
