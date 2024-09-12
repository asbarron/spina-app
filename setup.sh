#!/bin/sh
# Generate a secret key for Rails
SECRET_KEY_BASE=$(rails secret)

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

# bugfix for spina not getting latest version: https://github.com/SpinaCMS/Spina/issues/1379
echo "gem 'spina', '~> 2.18'" >> Gemfile

bundle install

# Install Spina
rails g spina:install --force --silent
rails db:migrate

mv seeds.rb db/seeds.rb
rails db:seed

# Set environment variable for SECRET_KEY_BASE
export SECRET_KEY_BASE=$SECRET_KEY_BASE

# Start app
puma -C config/puma.rb --redirect-stdout log/puma.stdout.log --redirect-stderr log/puma.stderr.log