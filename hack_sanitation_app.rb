# HackSanitation SMS handler
# Original by Joseph Abrahamson <me@jspha.com>

require 'sinatra'
require 'sinatra/r18n'
require 'twilio-ruby'
require 'data_mapper'

require './resources/subscription.rb'
require './resources/person.rb'

# TODO Validate that Twilio is actually sending these messages
# TODO Validate via Digest
# TODO Validate via HTTP Basic


class HackSanitationApp < Sinatra::Base

  # Set up i18n
  register Sinatra::R18n
  set :root, File.dirname(__FILE__)

  # Create our DataMapper
  @dm = DataMapper.setup(:default, "sqlite3::memory:")

  # These ENV variables must be configured via 'heroku config'
  @twilio_sid   = ENV['TWILIO_SID']
  @twilio_token = ENV['TWILIO_TOKEN']
  @client = Twilio::REST::Client.new( @twilio_sid, @twilio_token )

  # This is the core route for the whole shebang
  post '/sms/incoming/' do
    # --> parse Twilio request
    # This part needs to be changed for another SMS handler in Ghana
    from = params["From"]
    body = params["Body"]

    if from and body
      # Store that this person has been seen
      touch_person from

      # Do the parsing
      commands = parse_commands t.commands, body
      tags     = parse_hashtags body
      person   = lookup_person from
      
      # Handle the response
      response = handle_response commands, tags, person

      [200, {}, "<Response>#{response}</Response>"]
    else
      404  # What happened? Not Twilio, apparently
    end
  end


  private

  # The core of the response logic lives here
  def handle_response commands, tags, person
    return "Hello!"
  end

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

  # Run the app if this is executed as a file
  run! if app_file == $0
end
