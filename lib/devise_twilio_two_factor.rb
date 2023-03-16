# frozen_string_literal: true
require "devise"
require_relative "devise_twilio_two_factor/version"
require_relative "devise_twilio_two_factor/models"
require_relative "devise_twilio_two_factor/strategies"

module DeviseTwilioTwoFactor
  class Error < StandardError; end
  # Your code goes here...
end

Devise.add_module(:twilio_two_factor_authenticatable, :route => :session,
                  :strategy => true, :controller => :sessions, :model => true)
