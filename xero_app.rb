# This is an example app that provides a dashboard to make some example
# calls to the Xero API actions after authorising the app via OAuth 2.0.

require 'sinatra'
require 'sinatra/reloader' if development?
require 'xero-ruby'
require 'securerandom'
require 'dotenv/load'
require 'jwt'
require 'pp'

enable :sessions
set :session_secret, "328479283uf923fu8932fu923uf9832f23f232"
use Rack::Session::Pool
set :haml, :format => :html5

# Setup the credentials we use to connect to the XeroAPI
CREDENTIALS = {
  client_id: ENV['CLIENT_ID'],
  client_secret: ENV['CLIENT_SECRET'],
  grant_type: 'client_credentials'
}

# We initialise an instance of the Xero API Client here so we can make calls
# to the API later. Memoization `||=`` will return a previously initialized client.
helpers do
  def xero_client
    @xero_client ||= XeroRuby::ApiClient.new(credentials: CREDENTIALS)
  end

  def decode_token_set(token_set)
    if token_set && token_set['access_token']
      @access_token = JWT.decode token_set['access_token'], nil, false
    end
  end
end

# On the homepage, we need to define a few variables that are used by the
# 'home.haml' layout file in the 'views/' directory.
get '/' do
  @token_set = xero_client.get_client_credentials_token
  session[:token_set] = @token_set
  puts "session[:token_set]: #{session[:token_set]}"
  decode_token_set(@token_set)

  haml :home
end

# This endpoint is here specifically to obtain a new, valid access token at will.
get '/refresh-token' do
  @token_set = xero_client.get_client_credentials_token
  session[:token_set] = @token_set
  puts "session[:token_set]: #{session[:token_set]}"

  # Set some variables for the 'refresh_token.haml' view
  decode_token_set(@token_set)

  haml :refresh_token
end

# This endpoint allows the user to explicitly disconnect the app from
# their Xero contacts.
# Note: At this point in time, it assumes that you have a single contacts
# connected.

# This endpoint shows invoice data via the 'invoices.haml' view.
get '/invoices' do
  puts "session[:token_set]: #{session.inspect}"
  xero_client.set_token_set(session[:token_set])
  @invoices = xero_client.accounting_api.get_invoices('').invoices
  haml :invoices
end

# This endpoint returns the object of the first contacts that appears
# in the xero_client.connections array.
get '/contacts' do
  xero_client.set_token_set(session[:token_set])
  @contacts = xero_client.accounting_api.get_contacts('').contacts
  haml :contacts
end


get '/subscriptions' do
  creds = {
    client_id: ENV['APPSTORE_CLIENT_ID'],
    client_secret: ENV['APPSTORE_CLIENT_SECRET'],
    grant_type: 'client_credentials',
    scopes: ['marketplace.billing']
  }
  xero_app_store_client = XeroRuby::ApiClient.new(credentials: creds)
  xero_app_store_client.get_client_credentials_token

  @subscription = xero_app_store_client.app_store_api.get_subscription("03bc74f2-1237-4477-b782-2dfb1a6d8b21")
  haml :subscription
end
