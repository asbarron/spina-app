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
# Add ostruct compatilbilty (and stop spamming me x_x)
echo "gem 'ostruct'" >> Gemfile

bundle install

# Install Spina
rails g spina:install --force --silent

# Configure Mobility and SSL for prod 
if [ "$RAILS_ENV" = "production" ]; then
  # https://github.com/shioyama/mobility/wiki/Introduction-to-Mobility-v1.0
  mv /app/mobility.rb /app/config/initializers/mobility.rb
  # Gen self signed SSL certs
  openssl req -x509 -newkey rsa:4096 -keyout /app/config/key.pem -out /app/config/cert.pem -days 365 -nodes -subj "/CN=localhost" 
  # update puma config to use SSL 
  sed -i '/port ENV.fetch("PORT") { 3000 }/a \ ssl_bind "0.0.0.0", "443", { key: "/app/config/key.pem", cert: "/app/config/cert.pem", verify_mode: "none" }' /app/config/puma.rb
  sed -i '/port ENV.fetch("PORT") { 3000 }/d' /app/config/puma.rb
fi
rails g controller Home index
sed -i '/Rails.application.routes.draw do/a \  root "home#index"' config/routes.rb
echo "<h1>Hello from ${RAILS_ENV}</h1>" > app/views/home/index.html.erb
rails db:migrate

if [ "$RAILS_ENV" = "development" ]; then
  mv seeds.rb db/seeds.rb
  rails db:seed
fi

# Set environment variable for SECRET_KEY_BASE
export SECRET_KEY_BASE=$SECRET_KEY_BASE

# Start the app
if [ "$RAILS_ENV" = "production" ]; then
  # Precompile assets
  rails assets:precompile
  puma -C config/puma.rb 
else
  puma -C config/puma.rb --redirect-stdout log/puma.stdout.log --redirect-stderr log/puma.stderr.log
fi
