#!/bin/sh

# Wait for the database to be ready
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 1
done

# Initialize a new Rails application
rails new . --force --database=postgresql

# Prepare the database
rails db:create
rails active_storage:install

# Add Spina to the Gemfile
echo "gem 'spina'" >> Gemfile
bundle install --quiet

cp -r account.rb /app/app/models/account.rb

# Install Spina
{ echo ""; } | rails g spina:install --force --skip-mount
rails db:migrate

# Start app
puma -C config/puma.rb