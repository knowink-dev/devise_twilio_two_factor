# frozen_string_literal: true
require 'rubygems'
require "devise"
require 'twilio-ruby'
require_relative "devise_twilio_two_factor/version"
require_relative "devise_twilio_two_factor/models"
require_relative "devise_twilio_two_factor/strategies"
require_relative "devise_twilio_two_factor/services"

module Devise
  mattr_accessor :otp_code_length
  @@otp_code_length = 6

  mattr_accessor :otp_sender_name
  @@otp_sender_name = "your app name"

  mattr_accessor :twilio_account_sid
  @@twilio_account_sid = "define account sid in devise.rb" 

  mattr_accessor :twilio_auth_token
  @@twilio_auth_token = "define this in your devise.rb"
end

Devise.add_module(:twilio_two_factor_authenticatable, :route => :session,
                  :strategy => true, :controller => :sessions, :model => true)
