require 'sinatra'
require 'sinatra/r18n'
require 'twilio-ruby'

# TODO Validate that Twilio is actually sending these messages
# TODO Validate via Digest
# TODO Validate via HTTP Basic

class HackSanitationApp < Sinatra::Base

  register Sinatra::R18n
  set :root, File.dirname(__FILE__)

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
      commands = parse_commands t.commands, body
      tags     = parse_hashtags body
      [200, {}, tags.join(' ')]
    else
      404  # What happened? Not Twilio, apparently
    end
  end


  private

  # Looks for all the command words in the message
  def parse_commands com, body
    # Accumulate our command dictionary
    dict = com.report + com.clean + com.follow + com.stop
    # Get the words from the body
    words = body.downcase.split(/\W+/)
    
    words & dict
  end

  # Looks for hashtags like #bang! ==> ['bang!']
  def parse_hashtags body
    # Get all the words
    words = body.downcase.split

    # Delete anything that isn't a hashtag
    words.delete_if do |w|
      not (w[0,1] == "#")
    end

    # Trim off the "#"s
    words.each { |w| w.slice!(0) }
  end

  run! if app_file == $0
end
