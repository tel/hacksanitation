require 'sinatra'
require 'sinatra/reloader'
require 'twilio-ruby'

# TODO Validate that Twilio is actually sending these messages
# TODO Validate via Digest
# TODO Validate via HTTP Basic

class HackSanitationApp < Sinatra::Base

  # These ENV variables must be configured via 'heroku config'
  @twilio_sid   = ENV['TWILIO_SID']
  @twilio_token = ENV['TWILIO_TOKEN']
  @client = Twilio::REST::Client.new( @twilio_sid, @twilio_token )

  post '/sms/incoming/' do
    # --> parse Twilio request
    # This part needs to be changed for another SMS handler in Ghana
    
    from = params["From"]
    body = params["Body"]
    
    if from and body
      [200, {}, body]
    else
      # What happened? It wasn't Twilio, apparently
      404
    end
  end

  run! if app_file == $0
end
