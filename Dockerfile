# Dockerfile

FROM ruby:3.3.5-bookworm

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client netcat-openbsd

# Set the working directory
WORKDIR /app/

# Set ARGS
ARG ENV
ARG RAILS_ENV
ARG DATABASE_URL

# Use ARGS in ENV
ENV ENV="${ENV}"
ENV RAILS_ENV="${RAILS_ENV}"
ENV DATABASE_URL="${DATABASE_URL}"

# Set ENV
COPY .env."${ENV}" .env

# Install Bundler and Rails
RUN gem install bundler rails

# Expose the Rails port
EXPOSE 3000

# Copy the setup script into the container
COPY setup.sh /app/setup.sh
RUN chmod +x /app/setup.sh

# Start the application
CMD ["./setup.sh"]
