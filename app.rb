require 'sinatra'
require 'haml'
require 'oauth2'
require 'httparty'

# The following ENV variables need to be set before deployment.
# CREST_ID = 'CREST Client ID'
# CREST_KEY = 'CREST Secret Key'
# CREST_CALLBACK_URL = 'CREST Callback URL'
# SLACK_TEAM = 'Slack team subdomain, <name>.slack.com'
# SLACK_WEBHOOK_URL = 'Slack incoming-webhook URL'

def oauth2_client
  oauth2_client ||= OAuth2::Client.new(ENV['CREST_ID'], ENV['CREST_KEY'], {
    site: 'https://login.eveonline.com',
    authorize_url: '/oauth/authorize',
    token_url:     '/oauth/token'
  })
end

class InviteRequest
  include HTTParty
  attr_accessor(:name, :corp, :email)
  def initialize(name,corp,email)
    @name = name
    @corp = corp
    @email = email
  end

  def submit
    self.class.post(ENV['SLACK_WEBHOOK_URL'],
                  body: { attachments: [{
                            fallback: "New Access Request from #{@name}",
                            title: 'Access Request',
                            fields: [
                              { title: 'Character Name', value: @name, short: true},
                              { title: 'Corporation', value: @corp, short: true},
                              { title: 'E-Mail', value: @email}]
                        }]
                  }.to_json)
  end
end

get '/' do
  haml :index
end

get '/authorize' do
  redirect oauth2_client.auth_code.authorize_url(redirect_uri: ENV['CREST_CALLBACK_URL'], response_type: 'code')
end

get '/verify' do
  access_token = oauth2_client.auth_code.get_token(params[:code], redirect_uri: ENV['CREST_CALLBACK_URL'])
  verification_info  = access_token.get('https://login.eveonline.com/oauth/verify').parsed
  @character_info = HTTParty.get("https://api.eveonline.com/eve/CharacterInfo.xml.aspx?characterID=#{verification_info["CharacterID"]}", verify: false).parsed_response['eveapi']['result']
  haml :verify
end

post '/verify' do
  @invite_request = InviteRequest.new(params[:name],params[:corp],params[:email])
  @invite_request.submit
  haml :complete
end