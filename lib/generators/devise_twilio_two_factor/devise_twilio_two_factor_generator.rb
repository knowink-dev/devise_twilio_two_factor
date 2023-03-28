require 'rails/generators'

module DeviseTwilioTwoFactor
  module Generators
    class DeviseTwilioTwoFactorGenerator < Rails::Generators::NamedBase
      desc 'Creates a migration to add the required attributes to NAME, and ' \
           'adds the necessary Devise directives to the model'

      def install_devise_twilio_two_factor
        create_devise_twilio_two_factor_migration
        inject_devise_directives_into_model
      end

    private

      def create_devise_twilio_two_factor_migration
        migration_arguments = [
                                "add_devise_twilio_two_factor_to_#{plural_name}",
                                "otp_required_for_login:boolean",
                              ]

        Rails::Generators.invoke('active_record:migration', migration_arguments)
      end

      def inject_devise_directives_into_model
        model_path = File.join('app', 'models', "#{file_path}.rb")

        class_path = if namespaced?
          class_name.to_s.split("::")
        else
          [class_name]
        end

        indent_depth = class_path.size

        content = [
                    "devise :twilio_two_factor_authenticatable"
                  ]

        content = content.map { |line| "  " * indent_depth + line }.join("\n") << "\n"

        inject_into_class(model_path, class_path.last, content)
      end
    end
  end
end
