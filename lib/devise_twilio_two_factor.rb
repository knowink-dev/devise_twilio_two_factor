# frozen_string_literal: true
require 'rubygems'
require "devise"
require 'twilio-ruby'
require_relative "devise_twilio_two_factor/version"
require_relative "devise_twilio_two_factor/models"
require_relative "devise_twilio_two_factor/strategies"

module DeviseTwilioTwoFactor
  class Error < StandardError; end
  # Your code goes here...
  mattr_accessor :otp_code_length
  @@otp_code_length = 6
end

Devise.add_module(:twilio_two_factor_authenticatable, :route => :session,
                  :strategy => true, :controller => :sessions, :model => true)
