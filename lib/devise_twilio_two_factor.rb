# frozen_string_literal: true
require "devise"
require_relative "devise_twilio_two_factor/version"
require_relative "devise_twilio_two_factor/models"
require_relative "devise_twilio_two_factor/strategies"

module DeviseTwilioTwoFactor
  class Error < StandardError; end
  # Your code goes here...
end
