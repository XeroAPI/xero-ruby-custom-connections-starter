This is a basic application showing how to get started with the Xero's official [xero-ruby](https://github.com/XeroAPI/xero-ruby) SDK

*It uses [Sinatra](https://github.com/sinatra/sinatra) which is a DSL for creating simple web applications in Ruby with minimal effort*

# Getting Started
### 1) Make sure you have at least Ruby 2.7 [installed](https://www.ruby-lang.org/en/documentation/installation/)
```bash
ruby -v
ruby 2.7.0
```

### 2) Create an app in Xero's developer portal
* Create a [free Xero user account](https://www.xero.com/us/signup/api/) (if you don't have one)
* Login to [Xero developer center](https://developer.xero.com/myapps)
* Click "New App" link
* Select Custom connection
* Enter your App name, company url
* Agree to terms and condition and click "Create App".
* On the "Authorisation details" page, select the scopes for your app and designate the authorised user.
* Click "Save and connect" button.
* Authorise the connection from the email sent to the designated user
* Back in "My Apps" > "App details", click "Generate a secret" button.
* Copy your client id and client secret and save for use later.

### 3) Clone app and rename `sample.env` to `.env` and replace with the required parameters
```bash
$ git clone git@github.com:XeroAPI/xero-ruby-custom-connections-starter.git
$ cd xero-ruby-custom-connections-starter/
$ mv sample.env .env
```
Replace `CLIENT_ID`, `CLIENT_SECRET` with your unique parameters

### 5) Install dependencies & run the app
```bash
$ bundle install
$ bundle exec ruby xero_app.rb
```

> Visit `http://localhost:4567/` and start exploring the code in your editor of choice 🥳

----

## Sample getting started code
Setting up and connecting to the XeroAPI with the `xero-ruby` SDK is simple.

Note that to use a Custom Connection with this SDK you still need to pass an empty string as the `xero-tenant-id`, which is the first parameter in every method call. This is because this type of API connection inherently knows which Xero org is connected and the XeroAPI already knows what org every API call is for when using an `access_token` generated by the `client_credentials` OAuth 2.0 flow.

```ruby
@xero_client = XeroRuby::ApiClient.new(credentials: {
  client_id: ENV['CLIENT_ID'],
  client_secret: ENV['CLIENT_SECRET'],
  grant_type: 'client_credentails'
})

get '/contacts' do
  @token_set = xero_client.get_client_credentials_token
  @contacts = xero_client.accounting_api.get_contacts('').contacts
end
```

Checkout `xero_app.rb` for all the sample code you need to get started for your own app!