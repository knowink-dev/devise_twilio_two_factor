# Devise Twilio Two Factor
- The "Devise Twilio Two-Factor Authentication Gem" is an integration solution that brings together the robust security features of the Devise gem and the reliable functionality of Twilio APIs.
- By leveraging the power of Devise and Twilio together, your application can offer enhanced security measures to your users, reducing the likelihood of unauthorized access and potential data breaches.


## Usage

To integrate the Devise Twilio Two-Factor Authentication Gem, you'll need:

- The [Devise gem](https://github.com/heartcombo/devise), set up according to their instructions
- A [Twilio](https://www.twilio.com/try-twilio) account
- A Twilio Verify Service
  - Create service in [Twilio Verify Console](https://www.twilio.com/console/verify/services)
  - [Twilio Verify API Docs](https://www.twilio.com/docs/verify/api)

## Setup
Add devise_twilio_two_factor to your Gemfile:
<br/>

```ruby
# Gemfile

gem 'devise_twilio_two_factor', '~> 0.1.1'
```
<br/>

Add twilio `twilio_account_sid`, `twilio_auth_token` and `twilio_verify_service_sid` to `config/initializers/devise.rb`
```ruby
  config.twilio_account_sid = "ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  config.twilio_auth_token = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  config.twilio_verify_service_sid = "VAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```
<br/>

From here, the generator should get you the rest of the way (you can skip the rest of the section):
```bash
./bin/rails generate devise_twilio_two_factor MODEL
```
<br/>

To add two-factor authentication to a model, simply add the Devise Twilio Two-Factor Authenticatable module and specify two options:

1) The otp_destination option should represent the field containing the phone number or email address where the OTP code will be sent.
2) The communication_type option should be set to either "sms" or "email" depending on the desired mode of communication.

Ex. for a user with a phone field -> user.phone = '+18001234567'
```ruby
  devise :twilio_two_factor_authenticatable, otp_destination: 'phone', communication_type: "sms"
```
<br/>

lastly, just create a migration to add  `otp_required_for_login:boolean` to the table of the resource you wish to add 2fa to.
<br/><br/>
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jliv316/devise_twilio_two_factor.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

