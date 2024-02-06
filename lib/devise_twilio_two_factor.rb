# frozen_string_literal: true
require "rubygems"
require "devise"
require "twilio-ruby"
require_relative "devise_twilio_two_factor/version"
require_relative "devise_twilio_two_factor/models"
require_relative "devise_twilio_two_factor/callbacks"
require_relative "devise_twilio_two_factor/services"
require_relative "devise_twilio_two_factor/rails"
require_relative "devise_twilio_two_factor/routes"
require_relative "devise_twilio_two_factor/controllers"

module Devise
  mattr_accessor :otp_code_length
  @@otp_code_length = 6

  mattr_accessor :twilio_account_sid
  @@twilio_account_sid = "ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

  mattr_accessor :twilio_auth_token
  @@twilio_auth_token = "token"

  mattr_accessor :twilio_verify_service_sid
  @@twilio_verify_service_sid = "VAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

  mattr_accessor :second_factor_resource_id
  @@second_factor_resource_id = "id"

  mattr_accessor :remember_otp_session_for_seconds
  @@remember_otp_session_for_seconds = 30.minutes

  mattr_accessor :delete_cookie_on_logout
  @@delete_cookie_on_logout = true
end

module TwoFactorAuthentication
  NEED_AUTHENTICATION = "need_two_factor_authentication?"
  REMEMBER_TFA_COOKIE_NAME = "remember_tfa"

  module Controllers
    autoload :Helpers, "devise_twilio_two_factor/controllers/helpers"
  end
end

Devise.add_module(:twilio_two_factor_authenticatable, :route => :twilio_two_factor,
                  :controller => :twilio_two_factor, :model => true)
