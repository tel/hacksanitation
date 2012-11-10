require 'data_mapper'

# A Subscription is a particular SMS "mailing list" that a person has
# signed up to. There are many and they may or may not have a hashtag
# or a name included.
class Subscription
  include DataMapper::Resource

  property :id, Serial, :field => :id
  property :name, String, :field => :name
  property :hashtag, String, :field => :hashtag
end
