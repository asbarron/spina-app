#!/bin/sh

# Wait for the database to be ready
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 1
done

# Initialize a new Rails application
rails new . --force --database=postgresql

# Install dependencies
bundle install

# Prepare the database
bundle exec rails db:create
bundle exec rails active_storage:install 

# Add Spina to the Gemfile
echo "gem 'spina'" >> Gemfile
bundle install 

# Install Spina
{ echo ""; } | rails g spina:install --force --skip-mount

# Start the server
exec bundle exec puma -C config/puma.rb
