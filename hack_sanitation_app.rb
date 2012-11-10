# HackSanitation SMS handler
# Original by Joseph Abrahamson <me@jspha.com>

require 'sinatra'
require 'sinatra/r18n'
require 'twilio-ruby'
# require 'data_mapper'

# require './resources/subscription.rb'
# require './resources/person.rb'

# TODO Validate that Twilio is actually sending these messages
# TODO Validate via Digest
# TODO Validate via HTTP Basic


class HackSanitationApp < Sinatra::Base

  # Set up i18n
  register Sinatra::R18n
  set :root, File.dirname(__FILE__)

  # Create our DataMapper
  # @dm = DataMapper.setup(:default, "sqlite3::memory:")

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
    if commands[0] == :report
      t.response.report.success(0).choice
    elsif commands[0] == :clean
      t.response.report.clean.success.choice
    elsif commands[0] == :follow
      t.response.report.follow.success.choice
    elsif commands[0] == :stop
      t.response.report.stop.success.choice
    else
      t.response.report.default.success.choice
    end
    commands
  end

  # Looks for all the command words in the message
  def parse_commands com, body
    commands = body.downcase.split(/\W+/).map { |w| map_to_command w, t.commands }
    commands.delete_if { |c| c.nil? }
    commands[0,1]
  end

  # Convert any command word to its cannonical version
  def map_to_command word, dict
    if dict.report.find_index word
      :report
    elsif dict.clean.find_index word
      :clean
    elsif dict.follow.find_index word
      :follow
    elsif dict.stop.find_index word
      :stop
    else
      nil
    end
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

  # Touches a person in the database, creating them if they don't
  # currently exist and just updating their "last_seen" value if they
  # do. Currently a nop!
  def touch_person phone
    nil
  end

  # Looks up a person in the database, currently this is a nop and
  # just returns false. The system is memoryless until the database
  # works!
  def lookup_person phone
    false
  end

  # Run the app if this is executed as a file
  run! if app_file == $0
end
