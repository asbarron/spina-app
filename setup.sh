#!/bin/sh

# Wait for the database to be ready
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 1
done

# Initialize a new Rails application
rails new spina --force --database=postgresql
cd spina

# Prepare the database
rails db:prepare
rails active_storage:install 

# Add Spina to the Gemfile
echo "gem 'spina'" >> Gemfile
bundle install 

# Install Spina
{ echo ""; } | rails g spina:install --force --skip-mount

# Start the server
puma
