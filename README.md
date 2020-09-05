# About

This is a larger ToDo List project built using the Sinatra web framework as a part of [Launch School's](https://launchschool.com) course **LS185 - Database Applications**, Lesson 2. In course LS175 we built this app using sessions alone, and this time we abstract session manipulation code into a `SessionPersistence` class, and eventually replace it with a `DatabasePersistence` class utilizing Postgres.

## How to Run the App

This app uses Ruby 2.6.3. After downloading all the code, from the command line simply do the following

1. `$ bundle install` - install all dependencies
2. `$ ruby todo.rb`. If this does not work try `$ bundle exec ruby todo.rb`
