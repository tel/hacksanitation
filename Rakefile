#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'data_mapper'
require 'resources/person'
require 'resources/subscription'

namespace :db do
  task :update do
    Person.auto_update!
    Subscription.auto_update!
  end
end
