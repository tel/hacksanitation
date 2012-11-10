require 'data_mapper'
require 'dm-timestamps'

# A Person object lightly tracks a phone number in the SMS
# system. This does not correspond to a User in the Facebook app, but
# instead just a phone number that we see from time to time.
class Person
  include DataMapper::Resource

  property :id, Serial, :field => :id
  property :phone, String, :field => :phone
  property :last_seen, DateTime, 
end
