module DeviseTwilioTwoFactor
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseTwilioTwoFactor::Controllers::Helpers
    end
  end
end
