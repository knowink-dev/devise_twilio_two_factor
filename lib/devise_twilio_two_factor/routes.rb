module ActionDispatch::Routing
  class Mapper
    protected

    def devise_twilio_two_factor(mapping, controllers)
      resource :twilio_two_factor, :only => [:show, :update, :resend_code], :path => mapping.path_names[:twilio_two_factor], :controller => controllers[:twilio_two_factor] do
        collection { get "resend_code" }
      end
    end
  end
end
